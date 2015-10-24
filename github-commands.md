#github commands#

```
git clone https://github.com/kyleiwaniec/w205Project.git
cd w205Project
```

Get all the branches:

```
git fetch
```

The first time, you'll need to checkout the dev branch, so you can create your own branch off of it
```
git checkout dev
git pull origin dev
```
Then make your own branch

```
git checkout -b carlos_dev
```

.. write some code ..
if you created new files, add them to git
```
git add path/to/file
```

then commit them with a meaningful message and push to origin
```
git commit -am "place the write fn inside the ondata fn"
git push origin carlos_dev
```

###Other commands:###


see what files have been changed
`git status`

see what changes have been made inside files
`git diff`

more TK.