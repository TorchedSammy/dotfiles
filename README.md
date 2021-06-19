<div align='center'>
	<h4>🌺 sammyette's dots 🌺 </h4>
	<blockquote>there ain't any place like ~</blockquote>
</div>
<img src='https://modeus.is-inside.me/qJIfUb1r.png' align='right' width='400px'>
<img src='https://modeus.is-inside.me/R57wJAmQ.png' align='right' width='400px'>

#### Welcome!
Here is my very own collection of configuration files for my Linux desktop experience.

#### Details
- WM • AwesomeWM (uses stable version!) :cloud: config included
- OS • Fedora
- Shell • [hilbish](https://github.com/Rosettea/Hilbish) (i made this!) :cloud: config included
- Terminal • Alacritty :cloud: config included
- Compositor • Picom (blurred, rounded corners) :cloud: config included
- Music Player • cmus
- Color Schemes •
  - Base16 Horizon Terminal Dark
  - Custom high contrast color scheme [:cloud: included](https://github.com/TorchedSammy/dotfiles/blob/master/schemes/wist/wist.yaml)
  - Custom MacOS-inspired color scheme [:cloud: included](https://github.com/TorchedSammy/dotfiles/blob/master/schemes/macos/macos.yaml)
- Text/Code Editor •
  - Neovim (nightly) :cloud: config included
  - Sublime Text 4
- Fetches • 
  - [Bunnyfetch](https://github.com/Luvella/bunnyfetch.sh)
  - Neofetch :cloud: config included
  - [Hilbifetch](https://github.com/Hilbis/Hilbifetch)
- Visualizer • cava
- Wallpapers • https://github.com/TorchedSammy/walls/
- Base16 manager • [flavours](https://github.com/Misterio77/flavours) :cloud: config included
- Browser • Google Chrome

#### Setup
If any other (potential) Fedora users are here:
I recommend you (re)install from the
[Fedora Everything installer](https://alt.fedoraproject.org/).  
This can give you a very minimal install compared to the normal installer
if the minimal install is selected and doesn't include GNOME/whatever
Fedora uses!!!

1. Install Awesome (of course) with your package manager  
  On Fedora, this is just:  
  ```
  sudo dnf install awesome
  ```  
2. [Setup RPM Fusion](https://rpmfusion.org/Configuration/) (free and nonfree)
3. Install Dependencies
  - Fedora
    - Software
      ```
      sudo dnf install cmus neofetch unzip discord cava pavucontrol wget
      ```  
      [Google Chrome Install Steps](https://docs.fedoraproject.org/en-US/quick-docs/installing-chromium-or-google-chrome-browsers/)
    - Other Packages
    ```
    sudo dnf install pulseaudio pulseaudio-utils playerctl playerctl-libs google-noto-cjk-fonts
    ```
4. Install Fonts
  - [Victor Mono](https://github.com/rubjo/victor-mono) (Terminal Font)
  - [San Francisco](https://github.com/blaisck/sfwin) (General text font)
  - [Typicons](https://github.com/fontello/typicons.font)  
    ```sh
    wget https://github.com/fontello/typicons.font/raw/master/font/typicons.ttf -P ~/.local/share/fonts/
    ```
  - Font Awesome 5
  - [Nerd Font](https://www.nerdfonts.com/font-downloads) (Currently JetBrains Mono Nerd Font is a hard requirement)
5. Install other software below:  
#### Hilbish
[Hilbish](https://github.com/Rosettea/Hilbish) is my own custom shell,
which runs Lua code.  
Everything in `bin/` is written in Lua and has Hilbish as the shebang, so to run those
you need it installed.

Installation instructions are at the hyperlink.

#### Picom
I use [picom](https://github.com/ibhagwan/picom) as my compositor for rounded
corners, blurring, all that fancy stuff. Since I'm using the git version,
installation steps will be at that link.

#### ss/ssf
[ss](https://github.com/TorchedSammy/dotfiles/blob/master/bin/ss) and
[ssf](https://github.com/TorchedSammy/dotfiles/blob/master/bin/ssf), 
my screenshot scripts, require `curl`, `maim`, `notify-send` and `xclip`.
It uploads to a ShareX host ([is-inside.me](https://is-inside.me)) and copies the URL.

Install dependencies:  
```
sudo dnf install maim xclip libnotify
```  
The packages should be the same on any other distro.  
If you actually intend on using it, check `ssf` for configuration!

#### Neovim
I use Neovim nightly since some of the plugins I use require it.  
To get it on Fedora,  

Enable the Copr repo:  
```
sudo dnf copr enable agriffis/neovim-nightly
```

And Install:
```
sudo dnf install -y neovim python3-neovim
```

6. Install config files
```lua
git clone https://github.com/TorchedSammy/dotfiles --recursive
cd dotfiles
cp .config/ .hilbishrc .xinitrc ~ -r
cp schemes/ ~/.local/share/flavours/base16/ -r -- To add custom color schemes to flavours
```

#### Special Thanks
- Bob/JavaCafe01 for their dotfiles: https://github.com/JavaCafe01/awedots

#### Software Comments
These are just some of the comments on what I use.
- Fedora
  - **The** most stable and all around greatest distro I've used.  
  My wifi drivers always work, since on other distros my wifi only works every other boot. Up to date, stable, very comfy.

- AwesomeWM
  - I've tried Openbox before, but I don't like the XML config and I much prefer writing Lua (and current me can't live without tiling).
  Awesome also just has all that I want.

- cmus
  - ncmpcpp was way too much of a hassle to setup, so I tried cmus and it has been very good.  

- Alacritty: I used to use kitty but it was pretty slow on startup and alacritty also has hot reload.  
  I used termite too but it was missing some features I had on kitty. (its also dead now, rip termite)  
  But I tried alacritty and am currently loving it.
  Fast startup, config hot reload, written in Rust :sunglasses:

