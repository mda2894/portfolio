#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef uint8_t BYTE;

int main(int argc, char *argv[])
{
    // validate argc
    if (argc != 2)
    {
        printf("Correct usage: ./recover INFILE");
        return 1;
    }

    FILE *infile = fopen(argv[1], "r");

    // check that file exists
    if (infile == NULL)
    {
        printf("File can not be opened");
        return 1;
    }

    int numBytes = 512;
    int numBlocks = 0;
    int numPhotos = 0;
    char outfileName[8];
    FILE *outfile;

    while (numBytes == 512)
    {
        BYTE buffer[512];
        numBytes = fread(buffer, 1, 512, infile);

        // if new photo
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
        {
            // close previous photo
            if (numPhotos != 0)
            {
                fclose(outfile);
            }

            // start new photo
            sprintf(outfileName, "%03i.jpg", numPhotos);
            outfile = fopen(outfileName, "w");
            fwrite(buffer, 1, numBytes, outfile);
            numPhotos++;
        }
        else if (numPhotos > 0)
        {
            fwrite(buffer, 1, numBytes, outfile);
        }
    }
    fclose(infile);
    fclose(outfile);
}
