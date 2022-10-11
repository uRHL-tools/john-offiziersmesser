# John's Offiziersmesser :shipit: :hocho: <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>


Offiziersmesser is a Swiss term that means officer's knife. So this is the officer knife of John the Ripper.

This tool, which is a **wrapper for the command line tool John the Ripper,** aims to simplify its usage.

It allows you to manage cracking sessions, pause, restore, and check the progress of each of them and also checking which passwords have been cracked so far. All that within the same interactive CLI.

## Usage

Execute it directly from terminal like any other script (you may need to change the execution permissions). For more usage information run: 

```
~/john_offiziersmesser.sh -h
```
or
```
~/john_offiziersmesser.sh --help
```

## Directory structure

```
.
├── logs
├── old-attacks
├── resources
├── results
└── sessions
    ├── completed
    └── uncompleted
```
- `logs/` --> offiziersmesser attack log
- `old-attacks/` --> When you crack a new set of passwords, the previous results are stored here, organized by date
- `resources/` --> some [extra resources](#resources)
- `results/` --> Unshadowed password files
- `sessions/completed/` --> Logs of sessions that had been completed
- `sessions/uncompleted/` --> Data of uncompleted sessions (this data allow to resume a session)


## Execution modes

### Normal mode

The usual execution mode, or 'normal' mode, the offiziersmesser allows you to select your **own password hash file**. You can unshadow them from passwd + shadow files. Or you can directly select an unshadowed password file.

To execute John's offiziersmesser in **normal mode** run:

```
~/john_offiziersmesser.sh
```
or
```
bash john_offiziersmesser.sh
```

### Lab mode

Although originally, this tool was designed for the course 'Security Engineering', it has been enhanced to adapt to other contexts.

**This mode is only intented for the SE laboratory**. It will look for a zip file, identified by the group number, which contains the passwd and shadow files to be combined.

To execute John's Offizersmesser in lab mode run:

```
~/john_offiziersmesser --lab
```


## Resources

The zip file contains the original set of passwords to be cracked for the laboratory. If you have no experience cracking passwords you can use this set as an starting point.

It contains 10 hashed passwords (you need to unshadow them) which follow, more less, a normal distribution. This means that approximately, 20% are short and easy, 60% medium length and difficulty, and the 20% remaining are long and 'random'.

> Hint: some passwords may have the prefix/suffix 'uc3m'. 

Additionally, you will find here an example of a custom set of rules. You can tell John to use these rules for an attack with the option `--rules=<rule name>`. Take into account that those rules are stored in the configuration file `/etc/john/john.conf`, so you will need to add your rules there to use them.

For more examples check the file `/etc/john/john.conf`, the offical [John documentation](https://www.openwall.com/john/doc/RULES.shtml) and some [tutorials](https://miloserdov.org/?p=5477).

## License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.