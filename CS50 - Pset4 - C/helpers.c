#include "helpers.h"
#include <math.h>

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            RGBTRIPLE *px = &image[i][j];
            int grayval = round((px->rgbtRed + px->rgbtGreen + px->rgbtBlue) / 3.0);
            px->rgbtRed = grayval;
            px->rgbtGreen = grayval;
            px->rgbtBlue = grayval;
        }
    }
    return;
}

// Convert image to sepia
void sepia(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            RGBTRIPLE *px = &image[i][j];
            int sepiaRed = round(0.393 * px->rgbtRed + 0.769 * px->rgbtGreen + 0.189 * px->rgbtBlue);
            int sepiaGreen = round(0.349 * px->rgbtRed + 0.686 * px->rgbtGreen + 0.168 * px->rgbtBlue);
            int sepiaBlue = round(0.272 * px->rgbtRed + 0.534 * px->rgbtGreen + 0.131 * px->rgbtBlue);
            if (sepiaRed > 255)
            {
                sepiaRed = 255;
            }
            if (sepiaGreen > 255)
            {
                sepiaGreen = 255;
            }
            if (sepiaBlue > 255)
            {
                sepiaBlue = 255;
            }
            px->rgbtRed = sepiaRed;
            px->rgbtGreen = sepiaGreen;
            px->rgbtBlue = sepiaBlue;
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        RGBTRIPLE reverse[width];
        for (int j = 0; j < width; j++)
        {
            reverse[j] = image[i][width - 1 - j];
        }
        for (int j = 0; j < width; j++)
        {
            image[i][j] = reverse[j];
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    RGBTRIPLE blur[height][width];
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int numCells;
            RGBTRIPLE blurCells[9];
            if (i == 0)
            {
                if (j == 0)
                {
                    numCells = 4;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j + 1];
                    blurCells[2] = image[i + 1][j];
                    blurCells[3] = image[i + 1][j + 1];
                }
                else if (j == (width - 1))
                {
                    numCells = 4;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j - 1];
                    blurCells[2] = image[i + 1][j];
                    blurCells[3] = image[i + 1][j - 1];
                }
                else
                {
                    numCells = 6;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j + 1];
                    blurCells[2] = image[i][j - 1];
                    blurCells[3] = image[i + 1][j];
                    blurCells[4] = image[i + 1][j + 1];
                    blurCells[5] = image[i + 1][j - 1];
                }
            }
            else if (i == (height - 1))
            {
                if (j == 0)
                {
                    numCells = 4;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j + 1];
                    blurCells[2] = image[i - 1][j];
                    blurCells[3] = image[i - 1][j + 1];
                }
                else if (j == (width - 1))
                {
                    numCells = 4;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j - 1];
                    blurCells[2] = image[i - 1][j];
                    blurCells[3] = image[i - 1][j - 1];
                }
                else
                {
                    numCells = 6;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j + 1];
                    blurCells[2] = image[i][j - 1];
                    blurCells[3] = image[i - 1][j];
                    blurCells[4] = image[i - 1][j + 1];
                    blurCells[5] = image[i - 1][j - 1];
                }
            }
            else
            {
                if (j == 0)
                {
                    numCells = 6;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i + 1][j];
                    blurCells[2] = image[i - 1][j];
                    blurCells[3] = image[i][j + 1];
                    blurCells[4] = image[i + 1][j + 1];
                    blurCells[5] = image[i - 1][j + 1];
                }
                else if (j == (width - 1))
                {
                    numCells = 6;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i + 1][j];
                    blurCells[2] = image[i - 1][j];
                    blurCells[3] = image[i][j - 1];
                    blurCells[4] = image[i + 1][j - 1];
                    blurCells[5] = image[i - 1][j - 1];
                }
                else
                {
                    numCells = 9;
                    blurCells[0] = image[i][j];
                    blurCells[1] = image[i][j + 1];
                    blurCells[2] = image[i][j - 1];
                    blurCells[3] = image[i - 1][j];
                    blurCells[4] = image[i - 1][j + 1];
                    blurCells[5] = image[i - 1][j - 1];
                    blurCells[6] = image[i + 1][j];
                    blurCells[7] = image[i + 1][j + 1];
                    blurCells[8] = image[i + 1][j - 1];
                }
            }

            // calculate average RGB values
            float sumRed = 0, sumGreen = 0, sumBlue = 0;

            for (int p = 0; p < numCells; p++)
            {
                sumRed += blurCells[p].rgbtRed;
                sumGreen += blurCells[p].rgbtGreen;
                sumBlue += blurCells[p].rgbtBlue;
            }

            blur[i][j].rgbtRed = round(sumRed / numCells);
            blur[i][j].rgbtGreen = round(sumGreen / numCells);
            blur[i][j].rgbtBlue = round(sumBlue / numCells);
        }
    }

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j] = blur[i][j];
        }
    }
    return;
}

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{
    RGBTRIPLE edges[height + 2][width + 2];
    RGBTRIPLE blackCell = {0, 0, 0};

    // create "edges" image, with black border
    for (int i = 0; i < height + 2; i++)
    {
        for (int j = 0; j < width + 2; j++)
        {
            if (i == 0 || i == height + 1 || j == 0 || j == width + 1)
            {
                edges[i][j] = blackCell;
            }
            else
            {
                edges[i][j] = image[i - 1][j - 1];
            }
        }
    }

    int kx[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
    int ky[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

    // detect edges in original image, using "edges" image
    for (int i = 1; i < height + 1; i++)
    {
        for (int j = 1; j < width + 1; j++)
        {
            RGBTRIPLE edgeCells[3][3] = {{edges[i - 1][j - 1], edges[i - 1][j], edges[i - 1][j + 1]},
                {edges[i][j - 1], edges[i][j], edges[i][j + 1]},
                {edges[i + 1][j - 1], edges[i + 1][j], edges[i + 1][j + 1]}

            };

            int rgx = 0, rgy = 0, ggx = 0, ggy = 0, bgx = 0, bgy = 0;

            for (int r = 0; r < 3; r++)
            {
                for (int c = 0; c < 3; c++)
                {
                    rgx += kx[r][c] * edgeCells[r][c].rgbtRed;
                    ggx += kx[r][c] * edgeCells[r][c].rgbtGreen;
                    bgx += kx[r][c] * edgeCells[r][c].rgbtBlue;
                    rgy += ky[r][c] * edgeCells[r][c].rgbtRed;
                    ggy += ky[r][c] * edgeCells[r][c].rgbtGreen;
                    bgy += ky[r][c] * edgeCells[r][c].rgbtBlue;
                }
            }

            int resRed = round(sqrt(pow(rgx, 2) + pow(rgy, 2)));
            int resGreen = round(sqrt(pow(ggx, 2) + pow(ggy, 2)));
            int resBlue = round(sqrt(pow(bgx, 2) + pow(bgy, 2)));

            if (resRed > 255)
            {
                resRed = 255;
            }
            if (resGreen > 255)
            {
                resGreen = 255;
            }
            if (resBlue > 255)
            {
                resBlue = 255;
            }

            image[i - 1][j - 1].rgbtRed = resRed;
            image[i - 1][j - 1].rgbtGreen = resGreen;
            image[i - 1][j - 1].rgbtBlue = resBlue;
        }
    }
    return;
}
