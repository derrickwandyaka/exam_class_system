export default function Avatar({ src, name = 'Student', className = '' }) {
  return (
    <span className={`avatar ${className}`.trim()} role="img" aria-label={name}>
      {src ? (
        <img src={src} alt="" />
      ) : (
        <svg viewBox="0 0 24 24" role="img" aria-label="Default profile picture">
          <path d="M12 12a4.25 4.25 0 1 0 0-8.5 4.25 4.25 0 0 0 0 8.5Zm0 2c-4.1 0-7.5 2.1-7.5 4.7V21h15v-2.3c0-2.6-3.4-4.7-7.5-4.7Z" />
        </svg>
      )}
    </span>
  );
}
