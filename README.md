## Git Batch Push Script

When pushing large Git repositories to GitHub (such as the Android source code repository), you may encounter push failures due to remote limitations, network issues, and other problems. This project aims to solve this issue.

This script can be used to push local Git branch commits to the remote repository in batches, based on each commit. It automatically calculates the size of each push batch and displays the count of local commits and remote synchronized commits before each push.

### Usage

1. Clone or download the code repository to your local computer.
2. Use the command-line terminal to navigate to the directory where the script is located.
3. Run the following command to ensure you are working on the correct Git branch:

   ```
   git checkout <branch>
   ```

   where `<branch>` is the name of the branch you want to push.
4. Run the following command to execute the script:

   ```
   push.sh <path-to-your-project>
   ```

   The script will automatically push your commits and display the counter values before each push.

   If you encounter any errors, diagnose and resolve them based on the script's output.

### Notes

- Before running the script, ensure that you have merged all local commits into the branch you want to push and that you have synchronized your branch with the remote repository.
- Before running the script, ensure that you have set the correct remote repository and branch name. You can use the following commands to check them:

   ```
   git remote -v
   git branch -a
   ```

- If you want to adjust the size of each batch, modify the `BATCH_SIZE` variable in the script. By default, it is automatically calculated based on the number of commits.
- If you want to change other settings in the script, please refer to the comments in the script.

----------------------------------------------------------------------------------

## Git 批量推送脚本

当提交超大的GIT仓库到github时(比如Android源码仓库)，常常会因为远端限制、网络原因等问题导致推送失败，本项目就是为了解决这个问题。

这个脚本可以用来按commit分批推送本地 Git 分支的提交到远程仓库。它会自动计算每个推送批次的大小，并且在每个提交的推送之前显示当前本地提交的计数和远程同步的提交的计数。

### 使用方法

1. 克隆或下载代码库到本地计算机。
2. 使用命令行终端进入脚本所在的目录。
3. 执行以下命令来确保您在正确的 Git 分支上工作：

   ```
   git checkout <branch>
   ```

   其中，`<branch>` 是您想要推送的分支的名称。
4. 执行以下命令来运行脚本：

   ```
   push.sh <path-to-your-project>
   ```

   脚本将自动推送您的提交，并在每次推送之前显示计数器值。

   如果您遇到任何错误，请根据脚本输出进行诊断并解决它们。

### 注意事项

- 在运行脚本之前，请确保您已经将所有本地的提交合并到您想要推送的分支上，并且您已经与远程仓库同步了您的分支。
- 在运行脚本之前，请确保您已经设置了正确的远程仓库和分支名称。您可以使用以下命令来检查它们：

   ```
   git remote -v
   git branch -a
   ```

- 如果您想要调整每个批次的大小，请修改脚本中的 `BATCH_SIZE` 变量。默认情况下，它将根据提交数自动计算。
- 如果您想要更改脚本的其他设置，请参考脚本中的注释。