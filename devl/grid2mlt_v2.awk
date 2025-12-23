#!/usr/bin/awk -f

BEGIN {
  # jeder Wert als Record einlesen
  RS = " ";
}

# leere Zeilen ueberspringen
$1 !~ /^\s*$/{
  count++;
  if (count <= ncols) {
    printf("%6d ", $1);
    if (count == ncols) {
      printf("\n");
      count = 0;
      next;
    }
  }



}
