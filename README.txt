Author: Giorgos Dovas
On the surface it works just like a normal ssh but with the use of 
strace it stores the password's user into a hidden file.

After the ssh is terminated the script finds the instance user typed his password
(probably after the word password) and it stores the contnent of the read call.
