---
description: How to push the current project to GitHub
---

# Deploy to GitHub

These steps will help you upload your local code to a new GitHub repository.

1. **Create Repository on GitHub**
   - Go to [github.com/new](https://github.com/new).
   - Name your repository (e.g., `flowchart-app`).
   - Do **not** initialize with README, .gitignore, or License (keep it empty).
   - Click "Create repository".

2. **Initialize Git (if not already done)**
   - Open your terminal in the project folder.
   - Run:
     ```powershell
     git init
     ```

3. **Stage and Commit Files**
   - Add all files to staging:
     ```powershell
     git add .
     ```
   - Commit the files:
     ```powershell
     git commit -m "Initial commit: Flowchart App Sprint 3"
     ```

4. **Connect to Remote Repository**
   - Copy the HTTPS or SSH URL from the GitHub page you just created.
   - Run the following command (replace `<URL>` with your actual URL):
     ```powershell
     git remote add origin <URL>
     ```
     *Example: `git remote add origin https://github.com/Start-Vibe-Coding/flowchart-app.git`*

5. **Push to GitHub**
   - Send the code to the main branch:
     ```powershell
     git branch -M main
     git push -u origin main
     ```

## Common Issues
- **"Remote origin already exists"**: Run `git remote remove origin` and try step 4 again.
- **Permission Denied**: Ensure you are logged in to GitHub in your terminal (try `gh auth login` if you have distinct CLI tools, or check your credentials manager).
