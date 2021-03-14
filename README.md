#### Hi there!
<img src='https://modeus.is-inside.me/lFAxEOA9.png' align='right' width='400px'>

Welcome to this dotfiles repo.

Here is my personal configuration for my Linux desktop,  
using AwesomeWM since best WM,
and a couple other apps and tools.  

#### Details

- OS • Fedora Linux
- WM • AwesomeWM (uses stable version!) :cloud: config included
- Shell • zsh (no oh-my-zsh!) :cloud: config included
- Terminal • Alacritty :cloud: config included
- Compositor • Picom (blurred, rounded corners) :cloud: config included
- File Manager • ranger
- Music Player • cmus
- Color Schemes • Base16 Horizon Terminal Dark,
custom MacOS-inspired color scheme :cloud: MacOS colors included
- Text/Code Editor • Neovim (nightly) :cloud: config included
- Fetches • [Bunnyfetch](https://github.com/Luvella/bunnyfetch.sh), Neofetch :cloud: config included
- Visualizer • cava :cloud: config included

#### Setup
If any other (potential) Fedora users are here:
I recommend you (re)install from the
[Fedora Everything installer](https://alt.fedoraproject.org/).

1. Install Awesome (of course) with your package manager  
  ```
  sudo dnf install awesome
  ```

  Debian/Ubuntu and distros based on it can install with:  
  ```
  sudo apt install awesome
  ```

2. Install other dependencies
#### Other Packages
```
sudo dnf install pulseaudio pulseaudio-utils pavucontrol cava playerctl ranger google-noto-cjk-fonts cmus neofetch unzip git
```

#### Fonts
I use [JetBrains Mono](https://www.jetbrains.com/lp/mono/) for the terminal
font and Apple's [San Francisco](https://github.com/blaisck/sfwin) for
anything else text.  

[Typicons](https://www.s-ings.com/typicons/) and
Font Awesome 5 are required for icons.

Get a [Nerd Font](https://www.nerdfonts.com/font-downloads) so the file tree in Neovim has icons.

#### ss/ssf
[ss](https://github.com/TorchedSammy/dotfiles/blob/master/bin/ss) and
[ssf](https://github.com/TorchedSammy/dotfiles/blob/master/bin/ssf), 
my screenshot scripts, require `curl`, `jq`, `maim`, `notify-send` and `xclip`.
It uploads to a ShareX host ([is-inside.me](https://is-inside.me)) and copies the URL.

Installation on Fedora is:  
  ```
  sudo dnf install jq maim xclip libnotify
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

#### Ueberzug
Alacritty doesn't like w3m that much in my experience,
Ueberzug has been way better.

To install, first get `python-devel`:  
  ```
  sudo dnf install python-devel
  ```  

Then install ueberzug with pip:  
  ```
  sudo pip install ueberzug
  ```

3. Copy dotfiles
```
git clone https://github.com/TorchedSammy/dotfiles --recursive
cd dotfiles
cp config/* ~/.config -r
cp .zshrc ~
```

#### Comments
These are just some of the comments on what I use.
- Fedora: *the* most stable and all around greatest distro I've used.  
  My wifi drivers always work, since on other distros my wifi only works every other boot. It's just really solid.
- AwesomeWM: I've tried Openbox before, but I don't like the XML config and I much prefer writing Lua (and current me can't live without tiling).
  Awesome also just has all that I want.
- cmus: ncmpcpp was way too much of a hassle to setup, so I tried cmus and it has been very good.  
I also plan on making my own music player :^)
- Alacritty: I used to use kitty but it was pretty slow on startup and alacritty also has hot reload.  
  I used termite too but it was missing some features I had on kitty.  
  But I tried alacritty and am currently loving it.
  Fast startup, config hot reload, written in Rust :sunglasses:

