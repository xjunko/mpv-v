# World's Simplest Video Player

![](https://cdn.discordapp.com/attachments/703552229680087042/1081979595240243230/image.png)

![](https://cdn.discordapp.com/attachments/703552229680087042/1081981992377270364/image.png)
(even works with pipe!!!!)

# Building

Tested in Arch Linux (6.1.9-arch1-2), but I assumed it would work anywhere else as
long as you have `mpv` installed.

What I used:

```bash
clear && v fmt -w . && v -cc clang (or gcc) -d show_fps .
```
