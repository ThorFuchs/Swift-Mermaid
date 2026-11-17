# Security and resource limits

Understand the renderer's safeguards and their boundaries.

## Local rendering

The renderer passes source as a JavaScript argument, not as executable script.
The page loads bundled resources under a restrictive Content Security Policy,
blocks HTTP and HTTPS with a WebKit content rule, and rejects navigation away
from the bundled page. Rendering fails if the content rule can't be installed.
Mermaid runs with `securityLevel: 'strict'`; HTML labels are encoded and click
directives don't execute.

These layers reduce exposure but aren't a general-purpose sandbox or a promise
that arbitrary hostile input is safe. Applications that accept untrusted
source should apply their own input and resource policies. Don't treat output
as a sanitization boundary for other uses.

## Limits and deadlines

``MermaidRenderer/maximumSourceLength`` is 50,000 Swift characters. Mermaid
also enforces its own text and edge limits. Waiting for a renderer is limited
to 60 seconds; content-rule compilation, page loading, JavaScript rendering,
and PDF creation each have a separate 30-second deadline. These are individual
asynchronous deadlines, not a total time or a complete CPU and memory limit.
The cache limits entry count rather than total memory.

For private vulnerability reporting, see the repository's
[security policy](https://github.com/ThorFuchs/Swift-Mermaid/security/policy).
