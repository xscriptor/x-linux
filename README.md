<h1 align="center"> X Linux </h1>

<div align="center">
  <p><b>X</b> is a custom Arch Linux spin focused on simplicity, clean branding, and reproducible builds.</p>
  <p>It ships its own package repository (<a href="https://github.com/xscriptor/x-repo">x-repo</a>) so you can install X-specific packages directly with <code>pacman</code>.</p>
</div>

<blockquote>
  <p align="center"><b>Project status:</b> Under active development</p>
</blockquote>

<hr />

<h2 align="center"> Table of Contents </h2>
<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#the-x-repository">The X Repository</a> •
  <a href="#building-the-iso">Building the ISO</a> •
  <a href="#building-for-wsl">Building for WSL</a> •
  <a href="#archinstall-preconfiguration">Archinstall</a> •
  <a href="#post-installation-fallback">Post-installation</a> •
  <a href="#related-documents">Related Documents</a> •
  <a href="#x">X</a>
</p>

<hr />

<h2 align="center" id="overview"> Overview </h2>

<p>X provides a minimal yet polished Arch-based system with its own identity. It is built with the standard <code>mkarchiso</code> workflow, layering a custom profile, branding assets, and post-install automation.</p>

<h3 align="center"> Key Features </h3>
<ul>
  <li><b>Custom branding</b> — Identity applied to <code>/etc/os-release</code>, GRUB, MOTD, and wallpapers.</li>
  <li><b>X package repository</b> — Dedicated <code>[x]</code> repo in <code>pacman.conf</code> for branding and tools.</li>
  <li><b>Preconfigured archinstall</b> — Ships with <code>user_configuration.json</code> for hands-free installation.</li>
  <li><b>Post-install automation</b> — Scripts to apply branding to GNOME, KDE Plasma, XFCE, GDM, SDDM, and LightDM.</li>
  <li><b>WSL support</b> — Tools to build a WSL-importable tarball easily.</li>
</ul>

<hr />

<h2 align="center" id="project-structure"> Project Structure </h2>

<pre><code>x-linux/
├── profiledef.sh             # ArchISO profile definition
├── pacman.conf               # Package manager config (includes [x] repo)
├── packages.x86_64           # Package list for ISO build
├── airootfs/                 # Root filesystem overlay
│   ├── etc/
│   │   ├── os-release        # X system identity
│   │   ├── default/grub      # GRUB configuration
│   │   ├── motd              # Message of the Day
│   ├── root/
│   │   ├── x-autostart.sh    # Automated installation script
│   │   ├── x-postinstall.sh  # Post-install branding
│   │   └── user_configuration.json
├── xbuild.sh                 # Build ISO locally
├── xbuildwsl.sh              # Build WSL tarball
└── roadmap.md                # Project roadmap</code></pre>

<hr />

<h2 align="center" id="the-x-repository"> The X Repository </h2>

<p>The repository is pre-configured in <code>pacman.conf</code>:</p>

<pre><code>[x]
SigLevel = Optional TrustAll
Server = https://xscriptor.github.io/x-repo/repo/x86_64</code></pre>

<p>To add it to an existing Arch installation, append the block above to <code>/etc/pacman.conf</code> and run:</p>

<pre><code>sudo pacman -Sy x-release</code></pre>

<hr />

<h2 align="center" id="building-the-iso"> Building the ISO </h2>

<p>Install <code>archiso</code> and run the build script:</p>

<pre><code>sudo pacman -S archiso
./xbuild.sh</code></pre>

<p>The resulting <code>.iso</code> image will be stored inside the <code>./out/</code> directory.</p>

<hr />

<h2 align="center" id="building-for-wsl"> Building for WSL </h2>

<p>To create a tarball compatible with Windows Subsystem for Linux:</p>

<pre><code>sudo ./xbuildwsl.sh</code></pre>

<hr />

<h2 align="center" id="archinstall-preconfiguration"> Archinstall Preconfiguration </h2>

<p>The ISO includes a pre-configured <code>archinstall</code> profile for a streamlined installation process.</p>

<blockquote>
  <p><b>Note:</b> On some hardware, you may need to manually re-select the disk partitioning layout during the setup wizard.</p>
</blockquote>

<hr />

<h2 align="center" id="post-installation-fallback"> Post-installation (Fallback) </h2>

<p>If the X repository is unreachable, apply branding manually (while the new system is still mounted at <code>/mnt</code>):</p>

<pre><code>/root/x-postinstall.sh</code></pre>

<hr />

<h2 align="center" id="related-documents">Related Documents</h2>

<ul>
  <li><a href="./LICENSE">License</a></li>
  <li><a href="./CODE_OF_CONDUCT.md">Code of Conduct</a></li>
  <li><a href="./CONTRIBUTING.md">Contributions</a></li>
  <li><a href="./ROADMAP.md">Roadmap</a></li>
</ul>


<div align="center">
<h2 align="center" id="x">X</h2>

<a href="https://github.com/xscriptor">XGitHub</a> &middot;
<a href="https://dev.xscriptor.com">XWeb</a>
</div>