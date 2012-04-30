Example
=====

geoff@local:~/Documents/github/build/test$ build -l
target1

geoff@local:~/Documents/github/build/test$ build target1 
==[0]== building...
using            /Users/geoff/Documents/github/build/test/build.yaml
target           target1
source dir       /Users/geoff/Documents/github/build/test/
building to      /Users/geoff/Documents/github/build/test/.build/target1/
deploying to     /Users/geoff/Documents/github/build/test/.deploy/
=== done

geoff@local:~/Documents/github/build/test$ cat .deploy/afile
Hi, planet.

preprocess this!

geoff@local:~/Documents/github/build/test$ cat .deploy/anotherfile 
Greetings.

geoff@local:~/Documents/github/build/test$ git clone .repo/target1/ deploy_repo
Cloning into 'deploy_repo'...
done.

geoff@local:~/Documents/github/build/test$ cd deploy_repo/

geoff@local:~/Documents/github/build/test/deploy_repo$ ls -l
total 16
-rw-r--r--  1 geoff  staff  30 Apr 30 12:37 afile
-rw-r--r--  1 geoff  staff  11 Apr 30 12:37 anotherfile

geoff@local:~/Documents/github/build/test/deploy_repo$ cat afile 
Hi, planet.

preprocess this!

geoff@local:~/Documents/github/build/test/deploy_repo$ cat anotherfile 
Greetings.
