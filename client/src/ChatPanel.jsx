import { useEffect, useRef, useState } from 'react';
import { api } from './api';
import { useToast } from './Toast';
import Avatar from './Avatar';

function formatMessageTime(value) {
  const date = new Date(value);
  return Number.isNaN(date.getTime())
    ? ''
    : new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' }).format(date);
}

export default function ChatPanel({
  admin = false,
  student = null,
  lecturer = null,
  targetRoom = 'GLOBAL',
  courseUnit = null,
  onRead,
  fullPage = false
}) {
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [contactMessageId, setContactMessageId] = useState(null);
  const [editingMessageId, setEditingMessageId] = useState(null);
  const [editText, setEditText] = useState('');
  const [savingMessageId, setSavingMessageId] = useState(null);
  const [deletingMessageId, setDeletingMessageId] = useState(null);
  const messagesEndRef = useRef(null);
  const pollErrorShown = useRef(false);
  const lastMarkedMessageId = useRef(0);
  const onReadRef = useRef(onRead);
  const notify = useToast();
  const currentUserId = student?.id;

  useEffect(() => {
    onReadRef.current = onRead;
  }, [onRead]);

  useEffect(() => {
    let active = true;

    async function fetchMessages() {
      try {
        const endpoint = admin
          ? `/admin/messages?target_room=${encodeURIComponent(targetRoom)}`
          : lecturer
            ? `/lecturer/messages?course_unit_id=${courseUnit.id}`
            : `/messages${courseUnit ? `?course_unit_id=${courseUnit.id}` : ''}`;
        const latest = await api(endpoint);
        if (active) {
          setMessages(latest);
          pollErrorShown.current = false;
          if (student && latest.length) {
            const newestMessageId = Math.max(...latest.map((message) => Number(message.id) || 0));
            if (newestMessageId > lastMarkedMessageId.current) {
              lastMarkedMessageId.current = newestMessageId;
              try {
                await api('/chat/read', {
                  method: 'POST',
                  body: JSON.stringify({
                    ...(courseUnit ? { courseUnitId: courseUnit.id } : {}),
                    lastReadMessageId: newestMessageId
                  })
                });
                if (active) onReadRef.current?.();
              } catch (error) {
                lastMarkedMessageId.current = 0;
                if (active) notify(error.message || 'Could not mark this chat as read.', 'error');
              }
            }
          }
        }
      } catch {
        if (active && !pollErrorShown.current) {
          notify('Could not load chat updates. Please try again shortly.', 'error');
          pollErrorShown.current = true;
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    fetchMessages();
    const timer = window.setInterval(fetchMessages, 5000);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [admin, courseUnit?.id, lecturer?.id, notify, student?.id, targetRoom]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
  }, [messages]);

  async function sendMessage(event) {
    event.preventDefault();
    const message = text.trim();
    if (!message || sending) return;

    setSending(true);
    try {
      await api(lecturer ? '/lecturer/messages' : '/messages', {
        method: 'POST',
        body: JSON.stringify({
          text: message,
          ...(courseUnit ? { courseUnitId: courseUnit.id } : {})
        })
      });
      setText('');
      notify(admin ? 'Broadcast sent to all students.' : 'Message sent.');
    } catch (error) {
      notify(error.message || 'Could not send your message. Please try again.', 'error');
    } finally {
      setSending(false);
    }
  }

  function startEditing(message) {
    setEditingMessageId(message.id);
    setEditText(message.text);
  }

  function cancelEditing() {
    setEditingMessageId(null);
    setEditText('');
  }

  async function saveEdit(event, messageId) {
    event.preventDefault();
    const updatedText = editText.trim();
    if (!updatedText || savingMessageId !== null) return;

    setSavingMessageId(messageId);
    try {
      await api(`/messages/${messageId}`, {
        method: 'PUT',
        body: JSON.stringify({ text: updatedText })
      });
      setMessages((current) => current.map((message) => message.id === messageId
        ? { ...message, text: updatedText, editedAt: new Date().toISOString() }
        : message));
      cancelEditing();
      notify('Message updated.');
    } catch (error) {
      notify(error.message || 'Could not update your message. Please try again.', 'error');
    } finally {
      setSavingMessageId(null);
    }
  }

  async function deleteMessage(messageId) {
    if (deletingMessageId !== null) return;

    setDeletingMessageId(messageId);
    try {
      await api(`/messages/${messageId}`, { method: 'DELETE' });
      setMessages((current) => current.filter((message) => message.id !== messageId));
      if (editingMessageId === messageId) cancelEditing();
    } catch (error) {
      notify(error.message || 'Could not delete your message. Please try again.', 'error');
    } finally {
      setDeletingMessageId(null);
    }
  }

  return (
    <section className={`chat-panel card${admin ? ' admin-chat-panel' : ''}${fullPage ? ' chat-panel-full-page' : ''}`}
      aria-label="Chat and updates">
      <header className="chat-heading">
        <div>
          <h2>
            {admin
              ? targetRoom === 'GLOBAL' ? 'Global Chat' : `Group Chat: ${targetRoom}`
              : courseUnit
                ? `Class Chat: ${courseUnit.code} - ${courseUnit.name}`
                : student
                  ? `Group Chat: ${student.school} - ${student.degreeProgram} - ${student.program} (Year ${student.yearOfStudy}, Sem ${student.semester})`
                  : `Class Chat: ${courseUnit?.code || ''}`}
          </h2>
          <p className="muted small">
            {admin
              ? targetRoom === 'GLOBAL' ? 'Review global updates.' : 'Review messages for this group, including global updates.'
              : courseUnit
                ? 'Messages for students and the assigned lecturer in this class.'
                : 'Messages for your student group and global updates.'}
          </p>
        </div>
        <span className="chat-live"><span aria-hidden="true" /> Live updates</span>
      </header>

      <div className="chat-messages" role="log" aria-live="polite" aria-label="Recent messages">
        {loading ? (
          <div className="chat-loading"><span className="spinner" /> Loading messages…</div>
        ) : !messages.length ? (
          <p className="chat-empty muted">No messages in this chat yet. Start the conversation.</p>
        ) : messages.map((message) => message.isBroadcast ? (
          <article className="broadcast-message" key={message.id}>
            <div className="broadcast-title"><span aria-hidden="true">📣</span> Important update</div>
            <p>{message.text}</p>
            <div className="message-meta">{message.senderName} · {formatMessageTime(message.createdAt)}</div>
          </article>
        ) : (
          (() => {
            const isOwnMessage = (student && Number(message.senderId) === Number(currentUserId)) ||
              (lecturer && Number(message.senderLecturerId) === Number(lecturer.id));
            const isEditing = editingMessageId === message.id;
            const isSaving = savingMessageId === message.id;
            const isDeleting = deletingMessageId === message.id;
            const phoneNumber = typeof message.senderPhoneNumber === 'string'
              ? message.senderPhoneNumber.trim()
              : '';
            const phoneDigits = phoneNumber.replace(/\D/g, '');
            const phoneLink = `${phoneNumber.startsWith('+') ? '+' : ''}${phoneDigits}`;
            const hasContactNumber = !isOwnMessage && phoneDigits.length >= 7 && phoneDigits.length <= 15;
            const contactIsOpen = contactMessageId === message.id;
            const toggleContact = () => setContactMessageId(contactIsOpen ? null : message.id);

            return (
              <div className={`chat-message-row${isOwnMessage ? ' own' : ''}`} key={message.id}>
                {hasContactNumber ? (
                  <button type="button" className="chat-contact-avatar"
                    aria-label={`Show ${message.senderName}'s phone number`}
                    aria-expanded={contactIsOpen} onClick={toggleContact}>
                    <Avatar src={message.senderProfilePicture} name={message.senderName} className="chat-avatar" />
                  </button>
                ) : (
                  <Avatar src={message.senderProfilePicture} name={message.senderName} className="chat-avatar" />
                )}
                <article className="chat-message">
                  {hasContactNumber ? (
                    <button type="button" className="message-sender chat-contact-name"
                      aria-expanded={contactIsOpen} onClick={toggleContact}>
                      {message.senderName}
                    </button>
                  ) : (
                    <div className="message-sender">{message.senderName}</div>
                  )}
                  {isEditing ? (
                    <form className="chat-edit-form" onSubmit={(event) => saveEdit(event, message.id)}>
                      <textarea
                        value={editText}
                        onChange={(event) => setEditText(event.target.value)}
                        maxLength={2000}
                        rows={3}
                        required
                        aria-label="Edit message"
                        autoFocus
                      />
                      <div className="chat-edit-actions">
                        <button type="submit" className="chat-message-action save"
                          disabled={isSaving || !editText.trim()}>
                          {isSaving ? 'Saving…' : 'Save'}
                        </button>
                        <button type="button" className="chat-message-action"
                          onClick={cancelEditing} disabled={isSaving}>
                          Cancel
                        </button>
                      </div>
                    </form>
                  ) : (
                    <p>{message.text}</p>
                  )}
                  {contactIsOpen && hasContactNumber && (
                    <div className="chat-contact-number">{phoneNumber}</div>
                  )}
                  <div className="message-meta">
                    {formatMessageTime(message.createdAt)}{message.editedAt ? ' · Edited' : ''}
                  </div>
                  {isOwnMessage && !admin && !isEditing && (
                    <div className="chat-message-actions">
                      <button type="button" className="chat-message-action"
                        onClick={() => startEditing(message)} disabled={isSaving || isDeleting}>
                        Edit
                      </button>
                      <button type="button" className="chat-message-action delete"
                        onClick={() => deleteMessage(message.id)} disabled={isSaving || isDeleting}>
                        {isDeleting ? 'Deleting…' : 'Delete'}
                      </button>
                    </div>
                  )}
                  {hasContactNumber && (
                    <div className="chat-contact-actions" aria-label={`Contact ${message.senderName}`}>
                      <a className="chat-contact-link call" href={`tel:${phoneLink}`}>
                        Call
                      </a>
                      <a className="chat-contact-link whatsapp" href={`https://wa.me/${phoneDigits}`}
                        target="_blank" rel="noopener noreferrer">
                        WhatsApp
                      </a>
                    </div>
                  )}
                </article>
              </div>
            );
          })()
        ))}
        <div ref={messagesEndRef} />
      </div>

      {!admin && (
        <form className="chat-compose" onSubmit={sendMessage}>
          <div className="chat-compose-row">
            <textarea
              id="student-message"
              value={text}
              onChange={(event) => setText(event.target.value)}
              placeholder="Write a message…"
              maxLength={2000}
              rows={2}
              required
              aria-label="Chat message"
            />
            <button type="submit" className="btn primary" disabled={sending || !text.trim()}>
              {sending ? <><span className="spinner spinner-light" /> Sending…</> : 'Send'}
            </button>
          </div>
          <div className="chat-compose-hint">{text.length}/2000 characters</div>
        </form>
      )}
    </section>
  );
}
