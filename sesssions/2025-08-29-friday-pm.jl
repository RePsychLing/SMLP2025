# don't do this
# relative paths are subject to the present working directory
# the pwd might not match the file's location
read("../../somefile.txt", String)

# do this instead

@__FILE__ # the path to the currently executing file
@__DIR__ # the directory of the currently executing file

# to get the parent directory of a file or folder
# dirname("filename")
dirname(@__FILE__)

dirname(dirname(@__FILE__))

# don't build up paths as string concatenation because not everybody is doing windows/linux/mac
joinpath(dirname(dirname(@__FILE__)))

joinpath("path", "next", "etc")
