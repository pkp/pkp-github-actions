-   [PKP Github actions](#pkp-github-actions)
    -   [Requirements](#Requirements)
    -   [Usage](#usage)
        -   [Input variables](#input-variables)
    -   [Default configuration for
        OJS/OMP/OPS](#default-configuration-for-ojsompops)
        -   [Explanation](#explanation)
    -   [Default for pkp-lib or
        plugins](#default-for-pkp-lib-or-plugins)
        -   [Explanation](#explanation-1)
    -   [Development Scenarios](#development-scenarios)
        -   [Scenario 1: Only Application
            (ojs/omp/ops)](#scenario-1-only-application-ojsompops)
        -   [Scenario 2: Only pkp-lib](#scenario-2-only-pkp-lib)
        -   [Scenario 3: Application +
            pkp-lib](#scenario-3-application--pkp-lib)
    -   [Integration matrix](#integration-matrix)
    -   [References](#references)
    -   [Acknowledgements](#acknowledgements)
    -  
# PKP Github actions 


The PKP GitHub Actions facilitate automated testing for continuous integration within OJS, OMP, and OPS.

Presently, PKP applications incorporate unit tests (PHPUnit) and integrated tests (Cypress), alongside upgrade tests.
These tests undergo automated execution within a virtual environment, serving to prevent regressions and ensure 
the functionality of tested workflow steps.

## Plugins 
please refer to [plugins documentation](README_plugins.md)
## Usage
GitHub Actions have been integrated into the main and latest stable branches of PKP applications, 
and their configuration can be found in the following file_path `.github/workflows/main.yml`.

## Requirements

In main branch or OJS Versions released after 3.5, you will need the following  email setup to locally  run the cypress tests.

Install and run  Sendria  mail server  locally
- ```python3 -m pip install sendria```  [see details](https://pypi.org/project/sendria/)

Add the following mail settings to `config.inc.php` file

```
default = smtp
smtp = On
smtp_server = localhost
smtp_port = 1025
```
### Input variables


| Variable       | Description                                                         | Default        |
|----------------|---------------------------------------------------------------------|----------------| 
| application    | PKP Application (OJS\| OMP\| OPS)     (needed for pkp-lib)          | Current application |
| branch         | git branch         (needed for pkp-lib)                             | Current branch |
| dataset_branch | Identify the OJS Version:  3_3_0 for pkp/datasets                   | -              |
| debug_in_tmate | When a test fails anywhere, opens a tmate session, with ssh-server. |                |
| node_version   | can be set manually for older versions eg. 16.1.0                   | 20             |
| repository     | github repository name     (needed for pkp-lib)                     | Current repository |
| reset_commit   | Explicitly test a certain version of PKP Application                | -              |
| SAVE_BUILD     | if set, it will save the database to 'save_build'    pkp/datasets   |                |
| test           | run unit and integration tests 'test'                               |            |
| validate       | run valiadtoin tests  'validate'                                    |                |
| upgrade        | run upgrade tests  'upgrade'                                        |            |
| upgrade_test   | Identify the OJS Version: eg.g 3_3_0, 3_4_0,main  for upgrade_tests | -              |


##  Default configuration for OJS/OMP/OPS
```yml
 1. on: [push, pull_request]
 2. name: ojs
 3. jobs:
 4.   main:
 5.     runs-on: ubuntu-latest
 6.     strategy:
 7.       fail-fast: false
 8.       matrix:
 9.         include:
10.           - php-version: 8.1
11.             validate: 'validate'
12.           - php-version: 8.1
13.             database: pgsql
14.             upgrade: 'upgrade'
15.             upgrade_test: '3.1.0,3.1.1-2,
16.     name: ojs
17.     steps:
18.       - uses: pkp/pkp-github-actions@v1
19.       with :  
20.         node_version: 20
21.         dataset_branch: 'main'
22.         DATASETS_ACCESS_KEY:  ${{secrets.DATASETS_ACCESS_KEY}}
23.         DEBUG_IN_TMATE: false
                    
```
### Explanation
1. Github actions Runs on both `pull` and `pull requests`
2. name of the workflow
3. Defines the number of jobs , per action. We have one job , called main, run on 6 different settings, defined in the matrix. 
4. Name of the job
5. Runner Operating system: default Ubuntu and relies on the containers provided by github.com
6. defines the strategy of the current job
7. Run all the  jobs in matrix  independently
8. `matrix` configuration: defines the number of runners
9.  included tests
10. 1. Test - Currently tested PHP version
11. 1. Test - currently tested action type (validate| test| upgrade)12Test - Currently tested PHP version
12. 2. Test - Currently tested PHP version
13. 2. Test - currently  database type (mysql | pgsql | mariadb) 
14. 2. Test - currently tested action type (validate| test| upgrade)
15. 2. Test - Upgrade tests from earlier versions
16. name: of the action 
17. General definition for steps
18. Default integration is pkp-github-actions for OJS/OMP/OPS applications , but e.g. plugins, may run  extra github actions steps or use external github actions. 
19. Additional configurations 
20. node_version
21. For updating datasets, we have to define with ojs version, main / 3.4.0 / 3.3.0
22. Only needed if the datasets get saved to the  pkp/datasets, will only used for pkp-machine-user
23. This opens a tmate session, if any test fails

## Default for pkp-lib or plugins

```yml
1. on: [push, pull_request]
2. name: pkp-lib
3. jobs:
4.   pkp-lib:
5.     runs-on: ubuntu-latest
6.     strategy:
7.       fail-fast: false
8.       matrix:
9.         include:
10.           - application: ojs
11.             php-version: 7.3
12.             database: mysql
13.             test: 'test'
14.           - application: omp
15.             php-version: 7.4
16.             database: mysql
17.             test: 'test'
18.     name: pkp-lib
19.     steps:
20.       - uses: pkp/pkp-github-actions@v1
21.         with:
22.           repository: pkp
23.           branch: stable-3_3_0
24.           node_version: 12
25.           DEBUG_IN_TMATE: false

```
### Explanation

See above for the un-listed definitions. 

10. The application you are testing agains
22. you can define your own repository, if you are developing against that.
23. The  git branch , you are targetting your tests.

## Development Scenarios

### Scenario 1: Only Application (ojs/omp/ops)

This scenario  assumes, you are only doing enhancements or bugfixes to ojs,omp or ops

1. Clone branch of  your pkp-application to your development environment
   `git clone -b stable-3_4_0  https://github.com/pkp/ojs  $MY_PATH/ojs`
2. Optional: update your pkp-lib and other sub-modules to keep up with changes and include in push commits
  ` git submodule update --init --recursive -f; git add lib/pkp; git commit -m "Submodule update"`
3. Commit and push to your user git repository
4. Create your PR to  https://github.com/pkp/$application
  

 
### Scenario 2: Application + pkp-lib

If you are changing  both the pkp-lib and the application, follow one of the following strategies.
#### Step 1: Modify .gitmodules file in the application  e.g. ojs
1. **Update .gitmodules File:**
 You would change the URL to point to your repository temporarily for testing purposes.
```
[submodule "pkp-lib"]
       path = pkp-lib
       url = https://github.com/your_username/pkp-lib.git
       branch = my-feature-branch
```

Commits to your git user repository will trigger the tests automatically.

#### Step 2 : Change GitHub Workflow File in pkp-lb

E.g. Modify the GitHub workflow file located and commit to pkp-lib

https://github.com/your_username/pkp-lib/tree/feature_branch/.github/workflows/stable-3_4_0.yml

```
steps:
      - uses: pkp/pkp-github-actions@v1
        with:
          repository:your_username
          branch = my-feature-branch
```

#### Pull Request      
1. First create the PR against the pkp-lib
2. Then create the application PRs


## Integration matrix

|  Branch |Test-Type| PHP     | Database | DATASET_BRANCH | SAVE_BUILD | Container |
|----------| -- |---------|---------|----------------|------------|-----------|
 main     |validation| 8.1     |         |                |            | 1         | 
 main     |test| 8.1     | pgsql   |                | x          | 2         |
 main     |test| 8.1     | mariadb |                | x          | 3         
 main     |test| 8.1     | mysql   |                | x          | 1         
 main     |test| 8.2     | mysql   |                |            | 5         
 main     |test| 8.2     | pgsql   |                |            | 6         |
 main     |upgrade| 8.1     | mysql   | stable-3_4_0   |            | 1         
 main     |upgrade| 8.1     | mysql   | stable-3_3_0   |            | 1         
 main     |upgrade| 8.1     | pgsql   | stable-3_4_0   |            | 6         
 main     |upgrade| 8.1     | pgsql   | stable-3_3_0   |            | 6         
| ---      | ----  | ----| ----| ----| ----| ---- |
 3.4      |validation| 8       |         |                |            | 1         
 3.4      |test| 8       | pgsql   |                | x          | 2         
 3.4      |test| 8.1     | pgsql   |                |            | 3         
 3.4      |test| 8       | mariadb |                | x          | 4         
 3.4      |test| 8.1     | mysql   |                | x          | 5         |       
 3.4      |test| 8.2     | mysql   |                |            | 6         
 3.4      |test| 8.2     | pgsql   |                |            | 7         
 3.4      |test| | 8|  mysql                        |            | 7         
 3.4      |upgrade| 8       | mysql   | 3.1.0          |            | 7         
 3.4      |upgrade| 8       | mysql   | 3.1.1-2        |            | 7         
 3.4      |upgrade| 8       | mysql   | 3.1.2          |            | 7         
 3.4      |upgrade| 8       | mysql   | stable-3_2_0   |            | 7         
 3.4      |upgrade| 8       | mysql   | stable-3_2_1   |            | 7         
 3.4      |upgrade| 8       | mysql   | stable-3_3_0   |            | 7         
 3.4      |upgrade| 8       | pgsql   | 3.1.0          |            | 7         
 3.4      |upgrade| 8       | pgsql   | stable-3_2_0   |            | 7         
 3.4      |upgrade| 8       | pgsql   | stable-3_2_1   |            | 7         
 3.4      |upgrade| 8       | pgsql   | stable-3_3_0   |            | 7         
| ---      | ----  | ----| ----| ----| ----| ---- | 
 3.3      |validation| 8       |         |                |            | 1         |
 3.3      |test| 7.3     | pgsql   |                |            | 2         
 3.3      |test| 7.3     | mysql   |                |            | 3         
 3.3      |test| 7.4     | pgsql   |                |            | 4         
 3.3      |test| 7.4     | mysql   |                |            | 5         
 3.3      |test| 8       | pgsql   |                | x          | 6         
 3.3      |test| 8       | mysql   |                | x          | 7         
 3.3      |test| 8.1     | pgsql   |                |            | 8         
 3.3      |test| 8.1     | mysql   |                |            | 9         |
 3.3      |test| 8.2     | mysql   |                |            | 10        | 
 3.3      |test| 8.2     | pgsql   |                | | 11        |



## References
-  https://github.blog/2022-05-09-supercharging-github-actions-with-job-summaries/

## Acknowledgements
- During the development: chat.openai.com used as a help tool


### PHPStan integration

 pkp-github-actions was extened to support phpstan. Existing  application specific files can be integrated using the following two steps.
 
 
 1. Extend the tests e.g. [omp](https://github.com/withanage/omp/blob/php-stan/.github/workflows/stable-3_3_0.yml#L18) 
 
 ```yml
    - php-version: 8.0
    validate: 'validate'
    phpstan: 'true'
 ```
 
 2. Create a phpstan.neon file for the application and the branch and define the folders you would like to scan. 
      https://github.com/withanage/omp/blob/php-stan/phpstan.neon



 


#### Current issues

1.  Namespaces may not  is not working correctly, as global variables  have to be explicitly defined.
variables.  e.g. `define('BASE_SYS_DIR', dirname(INDEX_FILE_LOCATION));`

2.  There may be custom definitions needed for discovering file paths. https://phpstan.org/user-guide/discovering-symbols

 Sample OMP tests, failing 
 
 - https://github.com/withanage/omp/actions/runs/14150332670/job/39642633082#step:3:3110
 


 





