from sys import argv, exit
from cs50 import SQL


def main():
    if len(argv) != 2:
        print("Incorrect number of arguments")
        exit()

    db = SQL("sqlite:///students.db")

    house = argv[1]

    query = db.execute("SELECT * FROM students WHERE house = ? ORDER BY last, first;", house)

    for student in query:
        if student['middle']:
            print(f"{student['first']} {student['middle']} {student['last']}, born {student['birth']}")
        else:
            print(f"{student['first']} {student['last']}, born {student['birth']}")


if __name__ == "__main__":
    main()