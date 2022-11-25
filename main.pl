#!/usr/bin/perl

use 5.12.0;
use utf8;
use WebService::Discord::Webhook;
use DBI;

# Config
my $url = 'paste webhook URL here';
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my @month_name = qw(January February March April May June July August September October November December);
$year += 1900;
my $date = "@month_name[$mon] $mday, $year";

# Create the webhook object and DBI object
my $webhook = WebService::Discord::Webhook->new( $url );
my $dbh = DBI->connect("dbi:SQLite:questions.sqlite", { AutoCommit => 1, sqlite_unicode => 1 });

# Fetch ID of unsent questions from DB and pass to @questions array. If no questions are left then instead send an error to Discord and close DB connection
my @questions = @{ $dbh->selectcol_arrayref("SELECT id FROM data WHERE used = 0") };
if (@questions == 0) {
    $webhook->execute( content => 'There are no more questions left to post — please add more or you will get this message again tomorrow!');$dbh->disconnect; die}
else {
# Pick one fetched ID at random and pass to $q_id
    my $q_id = $questions[rand @questions];
# Request question text and source for selected ID and pass to $question_text and $source_text respectively
    my $question_text = $dbh->selectrow_array("SELECT question FROM data WHERE id = " . $q_id);
    my $source_text = $dbh->selectrow_array("SELECT source FROM data WHERE id = " . $q_id);
# Mark chosen question as used and record date
    $dbh->do("UPDATE data SET used = '1','when' = '" . time . "' WHERE id = " . $q_id);
# Set up "questions remaining" text
    my $remains;
    if ($#questions == 1) {$remains = ' question left'} else {$remains = ' questions left';};

# Post the message
    $webhook->execute( embed => {
        'title' => 'Question of the day for ' . $date,
        'description' => $question_text,
        'footer' => { 'text' =>  'Submitted by ' . $source_text . '  •  ' . $#questions . $remains },
        'color' => rand 16777215
    });

    if ($#questions == 0) {
        $webhook->execute( content => '**You\'re out of questions!** Please add more or no question will be posted tomorrow.');
        $dbh->disconnect; die
    } else { $dbh->disconnect; die }}
