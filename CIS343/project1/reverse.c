#include <stdio.h>

int main(int argc, char** argv) {

  FILE *infile, *outfile;
  int charCount = 0, i = 0;
  
  infile = fopen(argv[1], "r");
  outfile = fopen(argv[2], "w");

  if (!infile) {
    fprintf(stderr, "File doesn't exist. Aborting.");
    return 1;
  }

  // Move the file pointer to the end of the file
  fseek(infile, 0, SEEK_END);
  // Get the position at the end
  charCount = ftell(infile);

  while (i++ < charCount) {
    // Go backwards from the end character and write each one to the new file
    fseek(infile, -i, SEEK_END);
    fprintf(outfile, "%c", fgetc(infile));
  }

  // Close the files
  fclose(infile);
  fclose(outfile);
  
  return 0;
}
