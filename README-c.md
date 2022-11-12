# C implementation of the algorithm

## Build

```
cc -Wall -Wextra -pedantic LinearApprox.c -o LinearApprox
```

## Run

Program will read points by (x, y) coordinates line-by-line separated by space

```
printf -- "-2 3\n-1 2\n3 0.5\n4 -1\n" |./LinearApprox
```

Or using the bundled line generator (see --help) for usage

```
./generate_line.pl -A 5 -B 8 -x0 -5 --spread 1 -c 1000000 --step 0.3 > file
./LinearApprox < file
```

If the line generator was used with --spread parameter, the resulting values
will definitely have some accumulated error due to non-uniform nature of
rand() function which is added to the reference line: y = Ax + B + rand()
In that case line generator will print granular deltas info on stderr
along with sum of deltas.

Here is the script, which will build both functions (reference and
by averaged parameters) and summarize the delta between them.

```
./calculate_error.pl -origA 5 -origB 8 -testA 4.989169 -testB 8.048390 \
    -x0 0 -count 10
```

Complete example of this, please note the resulting accuracy of ZFLAM:

```
$ ./generate_line.pl -A -3 -B 4.25 -sp 1.15 -step 0.33 -x0 -50 -count 180 |
    ./LinearApprox
Real deltas:
0.156146530053552
...<long list of deltas>
0.150978163917482
Sum of deltas: 3.65889519073925
[rc=0] y = -3.000182 * x + 4.266604
$ ./calculate_error.pl -origA -3 -origB 4.25 -testA -3.000182 -testB 4.266604 \
    -step 0.33 -x0 -50 -count 180
Aggregate error: 3.65915340000055
```

