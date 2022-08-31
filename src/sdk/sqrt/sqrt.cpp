/**
 * @brief Square root source
 *
 */

#include <math.h>

double SquareRoot(const double value) {
  // Execute sqrt
  double res = sqrt(value);
  // NAN check
  if (res != res) {
    return -1.0;
  } else {
    return res;
  }
}
