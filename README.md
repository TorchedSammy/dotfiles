<div align='center'>
	<h4>🌺 sammyette's dots 🌺 </h4>
	<blockquote>there ain't any place like ~</blockquote>
</div>
<img src='https://modeus.is-inside.me/4WFOSEqq.png' align='right' width='400px'>

#### Welcome!
Here is my very own collection of configuration files for my Linux desktop experience.

#### Details
- WM • AwesomeWM (uses stable version!) :cloud: config included
- OS • Fedora
- Shell • [hilbish](https://github.com/Hilbis/Hilbish) (i made this!) :cloud: config included
- Terminal • Alacritty :cloud: config included
- Compositor • Picom (blurred, rounded corners) :cloud: config included
- Music Player • cmus
- Color Schemes •
  - Base16 Horizon Terminal Dark,
  - Custom Dracula inspired color scheme
  - Custom MacOS-inspired color scheme [:cloud: included](https://github.com/TorchedSammy/dotfiles/blob/master/schemes/macos/macos.yaml)
- Text/Code Editor • Neovim (nightly)
- Fetches • 
  - [Bunnyfetch](https://github.com/Luvella/bunnyfetch.sh),
  - Neofetch :cloud: config included
  - [Hilbifetch](https://github.com/Hilbis/Hilbifetch)
- Visualizer • cava
- Wallpapers • https://github.com/TorchedSammy/walls/
- Base16 manager • [flavours](https://github.com/Misterio77/flavours) :cloud: config included
- Browser • Google Chrome (seriously)

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
2. Setup RPM Fusion
3. Install other dependencies
#### Other Packages
```
sudo dnf install pulseaudio pulseaudio-utils pavucontrol cava playerctl ranger \
google-noto-cjk-fonts cmus neofetch unzip git discord
```

#### Hilbish
[Hilbish](https://github.com/Hilbis/Hilbish) is my own custom shell,
which runs Lua code.  
Everything in `bin/` is written in Lua and has Hilbish as the shebang, so to run those
you need it installed.

Installation instructions are at the hyperlink.

#### Picom
I use [picom](https://github.com/yshui/picom) as my compositor for rounded
corners, blurring, all that fancy stuff. Since I'm using the git version,
installation steps will be at that link.

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
my screenshot scripts, require `curl`, `maim`, `notify-send` and `xclip`.
It uploads to a ShareX host ([is-inside.me](https://is-inside.me)) and copies the URL.

Installation on Fedora is:  
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

4. Copy dotfiles
```lua
git clone https://github.com/TorchedSammy/dotfiles --recursive
cd dotfiles
cp .config/ ~ -r
cp .hilbishrc .xinitrc ~
cp schemes/ ~/.local/share/flavours/base16/ -r -- To add custom color schemes to flavours
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

