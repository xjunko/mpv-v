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

I don't have a windows machine currently but you should also be able to get it working as long as you point the compiler to mpv's dll.

# Featues

It has a _*lot*_ of features, such as:

- Playing a video or anything that `mpv` supports.
- That's about it really.
