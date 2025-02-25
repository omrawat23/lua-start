# Info.
This is a boilerplate for fivem to utilize lua and react together. This boilerplate in particular uses SCSS, which is a little different than regular css, but the main thing to know is that it works great with React.

# Dependencies
In order to use this template, you need to ensure you have a cfx default server installed. 
* A fivem server: https://youtu.be/uSLSiBYZBQY?si=M4VeoNQb7_v2uFaG
* Basic knowledge of React and NodeJS or yarn usage.

# Installation
* Download the repo via releases.
* Extract to your resources folder.
* Rename the file to whatever you want, and begin coding.
* Don't forget to add the name of your folder to your server.cfg file, and restart your server.

# Console commands required for UI:
* npm run build - Typing this into your VSCode console will make the react files compile into html, js, and css code, for FiveM to use as a UI.
* npm run watch - Typing this into your VSCode console will automatically build your files when you save. This is useful if you don't want to constantly type `npm run build` after every save.
* npm run dev - Typing this into your VSCode console will allow you to view your UI in your web browser. This is useful to avoid constantly restarting your script for little changes in the UI, such as moving a button 10 pixels.

# Help
If you are confused on how to get started with React, I recommend watching ReactJS tutorials on YouTube to get a basic understanding on how ReactJS works. There may not be a ton of videos covering ReactJS for UI in FiveM, but regular website building tutorials on ReactJS will teach you as much as you need.

I do have some tutorials going over using ReactJS and Typescript together for FiveM. You can watch these tutorials to learn a tiny bit of react, but it may be confusing, since the fivem script is not written in lua, it's written in Typescript.