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

###Everytime you are ready to do more work, pull from dev first###

Check that you are on the branch you want to be working in   
`git branch`   
now pull latest code updates from dev   
`git pull origin dev`   

do yer thing.. `add`, `commit`, `push`

###Other commands:###

see what files have been changed   
`git status`

see what changes have been made inside files   
`git diff`

more TK.

#####Awseome bit of bash I stole somewhere, can't remember where. This bit of awesomeness puts the name of the branch in front of my prompt, in a different color, if I am in a git repo. You can add it to your ~/.bash_profile if you are working on a mac. Not sure where you would put this on a PC:#####

```
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
PS1="\[\e[32m\]\$(parse_git_branch)\[\e[34m\]\h:\W \$ \[\e[m\]"
export PS1
```

#####I like this one too. Lets you view all the branches by date created#####

```
function branchesByDate {
  for k in `git branch|sed s/^..//`;do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cgreen%cr%Creset" "$k"`\\t"$k";done|sort
}
```

###Process###
'Cause the man knows what he's talkin' 'bout:
[http://scottchacon.com/2011/08/31/github-flow.html](http://scottchacon.com/2011/08/31/github-flow.html).


