
# Rolling Restarts

Performs a rolling restart of App Service instances.  This can help avoid downtime when restarting App Services.

## Getting Started

The default restart of App Services takes all instances offline at the same time.  However, the Azure Portal offers a method of restarting individual instances of the App Service.  However, there are no official PowerShell option to restart individual instances or perform a rolling restart of an App Service's instances.

In his [Blog](https://blogs.msdn.microsoft.com/david_burgs_blog/2018/07/11/powershell-script-to-restart-role-instances-for-webapp/), David Burg wrote a PowerShell script to perform a rolling restart of an App Service.  This extension makes use of that code, and some of Nate Scherer's adaptations to enable rolling restarts of App Services through VSTS (Azure DevOps).

### Prerequisites
This extension requires an existing App Service in an accessible Azure subscription.

## Configuration
![](https://raw.githubusercontent.com/cboroson/RollingRestart/master/RollingRestart-extension/Images/screenshot1.png)

## Contributing
Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* Craig Boroson

See also the list of [contributors](https://github.com/cboroson/RollingRestart/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* David Burg and Nate Scherer for base PowerShell code
