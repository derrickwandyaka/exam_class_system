import { Component } from 'react';

export default class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error, info) {
    console.error('The application encountered a rendering error:', error, info);
  }

  render() {
    if (this.state.hasError) {
      return (
        <main className="error-boundary">
          <section className="card error-boundary-card">
            <div className="brand-mark" aria-hidden="true">E</div>
            <h1>Something went wrong</h1>
            <p className="muted">Something went wrong, please refresh.</p>
            <button type="button" className="btn primary" onClick={() => window.location.reload()}>
              Refresh page
            </button>
          </section>
        </main>
      );
    }

    return this.props.children;
  }
}
