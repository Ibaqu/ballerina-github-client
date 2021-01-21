import ballerina/log;
import ballerina/io;
import ballerinax/github;

github:GitHubConfiguration gitHubConfig = {accessToken: getAccessToken()};

github:Client githubClient = new (gitHubConfig);

public function main(string... args) {
    github:Repository issueRepository = {
        owner: {login: "ballerina-platform"},
        name: "ballerina-lang"
    };

    GHIssue[] teamCompilerFE = [];
    GHIssue[] teamJBallerina = [];
    GHIssue[] teamC2C = [];
    GHIssue[] teamTestFramework = [];

    github:IssueList|error issuesOrError = githubClient->getIssueList(issueRepository, github:STATE_OPEN, 100);
    future<github:IssueList|error> closedIssuesFuture = start githubClient->getIssueList(issueRepository, github:STATE_CLOSED, 10);

    if issuesOrError is github:IssueList {
        foreach github:Issue issue in issuesOrError.getAllIssues() {
            issue.labels.forEach(function(github:Label label) {
                if label.name == "Team/CompilerFE" {
                    GHIssue ghIssue = new(issue.title);
                    teamCompilerFE[teamCompilerFE.length()] = ghIssue;
                }
                if label.name == "Team/jBallerina" {
                    GHIssue ghIssue = new(issue.title);
                    teamJBallerina[teamJBallerina.length()] = ghIssue;
                }
                if label.name == "Team/Code2Cloud" {
                    GHIssue ghIssue = new(issue.title);
                    teamC2C[teamC2C.length()] = ghIssue;
                }
                if label.name == "Team/TestFramework" {
                    GHIssue ghIssue = new(issue.title);
                    teamTestFramework[teamTestFramework.length()] = ghIssue;
                }
            });
        }
    } else {
        log:printError("Error occurred getting issues list: ", err = issuesOrError);
        return;
    }

    io:println("Team/CompilerFE - Issues(" + teamCompilerFE.length().toString() + ")");
    foreach GHIssue issue in teamCompilerFE {
        io:println("- " + issue.getName());
    }

    io:println("Team/jBallerina - Issues(" + teamJBallerina.length().toString() + ")");
    foreach GHIssue issue in teamJBallerina {
        io:println("- " + issue.getName());
    }

    io:println("Team/Code2Cloud - Issues(" + teamC2C.length().toString() + ")");
    foreach GHIssue issue in teamC2C {
        io:println("- " + issue.getName());
    }

    io:println("Team/TestFramework - Issues(" + teamTestFramework.length().toString() + ")");
    foreach GHIssue issue in teamTestFramework {
        io:println("- " + issue.getName());
    }

    github:IssueList closedIssues = checkpanic wait closedIssuesFuture;
    io:println("CLOSED - " + closedIssues.getAllIssues()[0].title);
}

class GHIssue {
    private string name;

    function init(string name) {
        self.name = name;
    }

    function getName() returns string {
        return self.name;
    }
}

function getAccessToken() returns string {
    return <@untainted>checkpanic io:fileReadString("/tmp/token.txt");
}
