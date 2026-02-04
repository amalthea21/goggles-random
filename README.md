# Goggles Random

NASM random number generator using systime for seeding

## Features:
- get random number in range x, y
- incredibly uneven distribution

## Buidling: / Running:

For building, you just need to make the build script executable and run it:

```sh
chmod +x build.sh
./build.sh
```

For running it, you run the build script with the run argument.

```sh
./build.sh run [Arguments]
```

## Arguments:
```
./build.sh run [MIN] [MAX]
```

- Min: Min must be under 8-byte big (2^64-1)
- Max: ^

## Limitations:

- Numbers can only be 8-byte big (2^64-1)

## Distribution:

With the file distribution_plot.py located in tests/, i got this result:

<img width="4770" height="1765" alt="grafik" src="https://github.com/user-attachments/assets/5e4815a9-121a-4e84-a7b5-178e5959152d" />

This result is pretty reproducable (multiple runs showed a similiar pattern - the outlier number just changes)
