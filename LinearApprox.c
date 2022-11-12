/*
 * vim: ts=4 sw=4 et ai :
 *
 * C implementation of ZFLAM (Zhmylove's Fast Linear Approx Method)
 * p5 version is avaiable on CPAN: Math::LinearApprox
 * Algorithm made by: KorG (Sergei Zhmylev)
 * Ilya Martynchuk was of great help to this implementation
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#define likely(x) __builtin_expect(!!(x), 1)
#define unlikely(x) __builtin_expect(!!(x), 0)

/*
 * Comment this out in order to use only decimal positive numbers:
 */
#define _FLOAT

#ifdef _FLOAT

#include <math.h>
#define COMPARE(A, B) (fabsl(A - B) < COMPARISON_DELTA)
#define COMPARISON_DELTA 0.0000001
#define POINT_FMT "%Lf"
typedef long double point_t;

#else /* _FLOAT */

#define COMPARE(A, B) (A == B)
#define POINT_FMT "%llu"
typedef unsigned long long point_t;

#endif /* _FLOAT */

/* The main model struct */
typedef struct model {
    unsigned long long N;
    point_t delta;
    point_t x_last;
    point_t x_sum;
    point_t y_last;
    point_t y_sum;
    point_t x_0;
} model_t;

/* `undef' replacement for C */
typedef enum rc {
    RC_OK,
    RC_EMPTY
} rc_t;

/* (A, B) = method() */
typedef struct result {
    rc_t rc;
    point_t A;
    point_t B;
} result_t;

/* Function to get the coefficients based on a model */
static inline result_t equation(const register model_t *M) {
    result_t rc = { RC_EMPTY, 0, 0 };

    if (unlikely(M->N <= 1)) {
        fprintf(stderr, "Too few points in model: %llu\n", M->N);
        return rc;
    }

    if (unlikely(COMPARE(M->x_last, M->x_0))) {
        fprintf(stderr, "Vertical line at x = " POINT_FMT "\n", M->x_0);
        return rc;
    }

    point_t delta;
    point_t x1;
    point_t y1;
    point_t x2;
    point_t y2;

    delta = M->delta / (M->x_last - M->x_0);
    x1 = M->x_sum / M->N;
    y1 = M->y_sum / M->N;
    x2 = x1 + 1;
    y2 = y1 + delta;

    rc.A = (y2 - y1) / (x2 - x1);
    rc.B = y2 - (x2 * (y2 - y1)) / (x2 - x1);
    rc.rc = RC_OK;

    return rc;
}

/* static inline func won't be inlined here, so the only way to do this: */
#define add_point(M, x, y) do {         \
    if (unlikely(M->N == 0))            \
        M->x_0 = x;                     \
    else                                \
        M->delta += y - M->y_last;      \
                                        \
    M->x_last = x;                      \
    M->x_sum += x;                      \
                                        \
    M->y_last = y;                      \
    M->y_sum += y;                      \
                                        \
    M->N++;                             \
    } while (0)

int main(int argc, char *argv[]) {   
    model_t M;
    point_t x_i;
    point_t y_i;

    memset(&M, 0, sizeof(model_t));
    memset(&x_i, 0, sizeof(point_t));
    memset(&y_i, 0, sizeof(point_t));

    while (fscanf(stdin, POINT_FMT " " POINT_FMT "\n", &x_i, &y_i) == 2) {
        add_point((&M), x_i, y_i);
    }

    result_t rc = equation(&M);
    fprintf(stdout,
            "[rc=%d] y = " POINT_FMT " * x + " POINT_FMT "\n",
            rc.rc,
            rc.A,
            rc.B);

    (void)argc, (void)argv;
    return 0;
}
