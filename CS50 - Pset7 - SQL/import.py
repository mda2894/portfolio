from sys import argv, exit
from cs50 import SQL
import csv


def main():
    if len(argv) != 2:
        print("Incorrect number of arguments")
        exit()

    db = SQL("sqlite:///students.db")
    db.execute("DELETE FROM students;")

    csvFile = argv[1]

    with open(csvFile, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['name'].split()
            house = row['house']
            birth = row['birth']

            first = name[0]
            last = name[-1]

            if len(name) == 3:
                middle = name[1]
            else:
                middle = None

            db.execute("INSERT INTO students (first, middle, last, house, birth) VALUES (?, ?, ?, ?, ?);",
                       first, middle, last, house, birth)


if __name__ == "__main__":
    main()