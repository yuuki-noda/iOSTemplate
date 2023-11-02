# iOSAppTemplate

## Prepare environment

1. Install Ruby using `rbenv`

   ```
   brew update
   brew install rbenv ruby-build
   echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
   source ~/.bash_profile
   ```

1. Install mint using `Genesis`

   ```
   brew install mint
   mint install Genesis
   ```

1. Make scripts executable

   ```
   chmod +x ./Scripts/*
   ```

1. Run setup script

   ```
   ./Scripts/bootstrap.sh
   ```
