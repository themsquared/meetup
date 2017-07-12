# How to run terraform grap to get a .png file

There is a dependency to perform this step you will need to install graphviz.  

You can get it via homebrew 

brew install graphviz

terraform graph | dot -Tpng > graph.png

