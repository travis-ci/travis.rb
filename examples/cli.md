##  Encrypt a file

Assumptions:

* The repository is set up on Travis CI
* You have the latest version of the Travis CI Command Line Client installed and setup up (you are logged in)
* You have a local copy of the repository and a terminal open where your current working directory is said copy
* In the repository is a file, called super_secret.txt, that you need on Travis CI but you don't want to publish its content on GitHub.

The file might be too large to encrypt it directly via the `travis encrypt` command. However, you can encrypt the file using a passphrase and then encrypt the passphrase. On Travis CI, you can use the passphrase to decrypt the file again.

The set up process looks like this:

1. **Come up with a password.** First, you need a password. We recommend generating a random password using a tool like pwgen or 1password. In our example we will use `ahduQu9ushou0Roh`.
2. **Encrypt the password and add it to your .travis.yml.** Here we can use the `encrypt comamnd`: `travis encrypt super_secret_password=ahduQu9ushou0Roh --add` - note that if you set this up multiple times for multiple files, you will have to use different variable names so the passwords don't override each other.
3. **Encrypt the file locally.** Using a tool that you have installed locally and that is also installed on Travis CI (see below).
4. **Set up decryption command.** You should add the command for decrypting the file to the `before_install` section of your `.travis.yml` (see below).

Be sure to add `super_secret.txt` to your `.gitignore` list, and to commit both the encrypted file and your `.travis.yml` changes.

### Using GPG

Set up:

``` console
$ travis encrypt super_secret_password=ahduQu9ushou0Roh --add
$ gpg -c super_secret.txt
(will prompt you for the password twice, use the same value as for super_secret_password above)
```

Contents of the `.travis.yml` (besides whatever else you might have in there):

``` yaml
env:
  global:
    secure: ... encoded secret ...
before_install:
  - echo $super_secret_password | gpg super_secret.txt.gpg
````

The encrypted file is called `super_secret.txt.gpg` and has to be committed to the repository.

### Using OpenSSL


Set up:

``` console
$ travis encrypt super_secret_password=ahduQu9ushou0Roh --add
$ openssl aes-256-cbc -k "ahduQu9ushou0Roh" -in super_secret.txt -out super_secret.txt.enc
(keep in mind to replace the password with the proper value)
```

Contents of the `.travis.yml` (besides whatever else you might have in there):

``` yaml
env:
  global:
    secure: ... encoded secret ...
before_install:
  - openssl aes-256-cbc -k "$super_secret_password" -in super_secret.txt.enc -out super_secret.txt -d
````

The encrypted file is called `super_secret.txt.enc` and has to be committed to the repository.