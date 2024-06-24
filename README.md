# World's Simplest Video Player

![image](https://github.com/xjunko/mpv-v/assets/44401509/b20f65fb-9055-4b09-a62d-c5afdd782f3f)
![image](https://github.com/xjunko/mpv-v/assets/44401509/2ff1f23c-731e-43e7-a9d5-5f98866eca27)

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
