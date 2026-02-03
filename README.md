# Goggles Random

NASM random number generator using systime for seeding

## Features:
- get random number in range x, y

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


