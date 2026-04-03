<h1 align="center"> Security Policy </h1>

<div align="center">
  <p>Protecting the X Linux ecosystem and its custom repositories</p>
</div>

<hr />

<h2 align="center" id="reporting-vulnerabilities"> Reporting Security Vulnerabilities </h2>

<p>If you discover a security vulnerability in <b>X Linux</b> (including exploits in the <code>xbuild</code> scripts, the <code>[x]</code> repository, or <code>x-release</code> branding hooks), please report it responsibly via email to:</p>

<p align="center">
  <b>Email:</b> <a href="mailto:x@xscriptor.com">x@xscriptor.com</a>
</p>

<blockquote>
  <b>Do not</b> open public GitHub issues for security vulnerabilities. Private disclosure allows us to fix the issue before it can be exploited.
</blockquote>

<h3 align="center"> What to Include </h3>
<p>When reporting a security issue, please provide:</p>
<ol>
  <li><b>Description</b> — A clear explanation of the vulnerability.</li>
  <li><b>Type</b> — The category of the issue (e.g., privilege escalation, repository compromise, installer script injection).</li>
  <li><b>Steps to Reproduce</b> — Detailed steps or a Proof of Concept (PoC) to trigger the vulnerability.</li>
  <li><b>Impact</b> — How severe is the issue? What could an attacker achieve on an installed system?</li>
  <li><b>Affected Component</b> — Which specific script (e.g., <code>x-postinstall.sh</code>) or package is affected?</li>
</ol>

<h3 align="center"> Guidelines </h3>
<ul>
  <li><b>Confidentiality</b> — Do not disclose the vulnerability publicly until a fix is released.</li>
  <li><b>Patience</b> — Please give the maintainers reasonable time to address the issue before public disclosure.</li>
  <li><b>Response Time</b> — We aim to acknowledge receipt within <b>7 days</b>.</li>
</ul>

<hr />

<h2 align="center" id="best-practices"> Security Best Practices for Users </h2>

<p>While X Linux is built to be a clean Arch spin, please keep these recommendations in mind:</p>
<ul>
  <li><b>Stay updated</b> — Regularly run <code>sudo pacman -Syu</code> to receive the latest security patches from both Arch and the <code>[x]</code> repository.</li>
  <li><b>Verify ISO Integrity</b> — Always verify the checksum of your built ISO before installation.</li>
  <li><b>Repository Trust</b> — Only use the official <code>[x]</code> repository as defined in the <code>pacman.conf</code> of this project.</li>
  <li><b>Post-install Audit</b> — If you modify the <code>airootfs</code> overlay, ensure you are not accidentally including sensitive credentials or insecure file permissions.</li>
</ul>

<hr />

<h2 align="center" id="supported-versions"> Supported Versions </h2>

<table align="center">
  <thead>
    <tr>
      <th>Version</th>
      <th>Status</th>
      <th>Support Until</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">latest (Rolling)</td>
      <td align="center">Active</td>
      <td align="center">latest</td>
    </tr>
  </tbody>
</table>

<hr />

<div align="center">
  <p><b>Thank you for helping keep X Linux secure!</b></p>
</div>