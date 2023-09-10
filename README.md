# i34Win
i3 but in windows.... kinda

Basically, what the description says. This is my attempt using borked up powershell and c# together to try an emulate the behavior you can get with i3. The only thing setting this apart from anything else is the attempt to do it all natively. This _should_ work in anything going all the way back to POSH 2.0. There are some tricks you could do to make it work in POSH 1.0, but I've only ever used 1.0 _once_ lol.

I know it's not good practice, but the other thing i like to have is self-contained POSH scripts. In my mind the scripts are for convenience, plus the class stuff was introduced in POSH 4 I think? So, while note best practice, I think for usability, single script files tend to work better in POSH. I also typically try to write to the standard of at least 2.0. Though I usually forgo the [System.Activator] trick over new-object or [thing]::new() just because it's a PITA.
