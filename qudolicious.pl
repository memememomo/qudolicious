use Mojolicious::Lite;
use utf8;
use Qudo;

app->plugin('charset' => {charset => 'utf-8'});

app->plugin(
    config => {
	file => app->home->rel_file('config.pl'),
	stash_key => 'config'
    }
);

app->helper(
    qudo => sub {
	Qudo->new( %{ app->config->{'Qudo'} } );
    }
);

get '/' => 'index';

get '/info/databases' => sub {
    my $self = shift;
    $self->stash->{databases} = [sort $self->qudo->shuffled_databases];
    $self->render();
} => 'info/databases';

get '/info/job_count' => sub {
    my $self = shift;
    $self->stash->{job_count} = $self->qudo->job_count();
    $self->render();
} => 'info/job_count';

get '/info/job_status' => sub {
    my $self = shift;
    $self->stash->{job_status_list} = $self->qudo->job_status_list();
    $self->render();
} => 'info/job_status';

get '/info/exceptions' => sub {
    my $self = shift;
    $self->stash->{exception_list} = $self->qudo->exception_list();
    $self->render();
} => 'info/exceptions';

app->start;


__DATA__

@@ layouts/wrapper.html.ep
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <title>Qudolicious</title>
    <style type="text/css">
       html { margin: 0em 0em; padding 0em 0em; background: #eeeeee none; }
       body { margin: 0em 0em; padding: 1em 1em; font-style: normal; font-weight: normal; color: #111111; }
       h1   { font-size: large; }
       a    { color: #0022aa; text-decoration: none; }
       a:hover,a:focus { color: #0033ee; text-decoration: underline; }
    </style>
  </head>
  <body>
    <ul>
      <li><a href="<%= url_for('info/databases') %>">Databases</a></li>
      <li><a href="<%= url_for('info/job_count') %>">Job Count</a></li>
      <li><a href="<%= url_for('info/job_status') %>">Job Status</a></li>
      <li><a href="<%= url_for('info/exceptions') %>">Exceptions</a></li>
    </ul>
    <hr />
    <%= content %>
  </body>
</html>


@@ index.html.ep
% layout 'wrapper';
<h1>Qudolicious Administration Interface</h1>


@@ info/databases.html.ep
% layout 'wrapper';
% for my $db ( @{ $databases } ) {
    <%= $db %><br />
% }


@@ info/exceptions.html.ep
% layout 'wrapper';
<% for my $dsn ( keys %{ $exception_list } ) { %>
     <%= $dsn %><br />
     <table>
         <tr>
             <th>id</th>
             <th>func_id</th>
             <th>exception_time</th>
             <th>message</th>
             <th>uniquekey</th>
             <th>arg</th>
             <th>retried</th>
         </tr>
     <% for my $exception ( @{ $exception_list->{$dsn} } ) { %>
         <tr>
             <td><%= $exception->{id} %></td>
             <td><%= $exception->{func_id} %></td>
             <td><%= $exception->{exception_time} %></td>
             <td><%= $exception->{message} %></td>
             <td><%= $exception->{uniqkey} %></td>
             <td><%= $exception->{arg} %></td>
             <td><%= $exception->{retried} %></td>
          </tr>
     <% } %>
     </table>
<% } %>


@@ info/job_count.html.ep
% layout 'wrapper';
<% for my $dsn ( keys %$job_count ) { %>
    <%= $dsn %><br />
    <%= $job_count->{$dsn} %><br />
<% } %>


@@ info/job_status.html.ep
% layout 'wrapper';
<% for my $dsn ( keys %{ $job_status_list } ) { %>
     <%= $dsn %><br />
     <table>
         <tr>
           <th>ID</th>
           <th>func_id</th>
           <th>arg</th>
           <th>uniqkey</th>
           <th>status</th>
           <th>job_start_time</th>
           <th>job_end_time</th>
         </tr>
     <% for my $w ( @{ $job_status_list->{$dsn} } ) { %>
         <tr>
           <td><%= $w->{id} %></td>
           <td><%= $w->{func_id} %></td>
           <td><%= $w->{arg} %></td>
           <td><%= $w->{uniqkey} %></td>
           <td><%= $w->{status} %></td>
           <td><%= $w->{job_start_time} %></td>
           <td><%= $w->{job_end_time} %></td>
         </tr>
     <% } %>
     </table>
<% } %>
