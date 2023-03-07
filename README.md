# World's Simplest Video Player

![](https://cdn.discordapp.com/attachments/703552229680087042/1082187511973019688/image.png)

![](https://cdn.discordapp.com/attachments/703552229680087042/1082187198109061120/2023-03-06_14-24.png)
(it even works with pipe!!!!)

# Building

Tested in Arch Linux (6.1.9-arch1-2), but I assumed it would work anywhere else as
long as you have `mpv` installed.

What I used:

```bash
clear && v fmt -w . && v -cc clang (or gcc) -d show_fps .
```

## To Windows User

* Get MPV Shared library from [libmpv@sourceforge.net](https://sourceforge.net/projects/mpv-player-windows/files/libmpv/)
* Copy `include` folder and `libmpv-2.dll` into project folder
* And you're ready to go!

# Features

It has a _*lot*_ of features, such as:

- Playing a video or anything that `mpv` supports.
- That's about it really.
