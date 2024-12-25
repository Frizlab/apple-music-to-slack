# How to Generate Those Files

This is all from <https://github.com/tingraldi/SwiftScripting>.

Pre-requisite:  
Clone the repo above and run `pip install --user 'clang<=16'` if you don’t have this dependency.

From the cloned repo:
1. `sdef /System/Applications/Music.app >Music.sdef`
2. `sdp -fh --basename Music Music.sdef`
3. `sbhc.py Music.h`
4. `sbsc.py Music.sdef`

You can then remove the `Music.sdef` and `Music.h` files.
