Introduction
============
The [force.com](http://developer.force.com/) platform provides built in Email messaging capabilities, but has a couple of key limits:

1. **Hard Sending Cap**:  You can only send 1,000 emails a day, regardless of how many users you have and there is no published way to purchase more capacity.
1. **Spam Filters**: Email from salesforce.com seems to be caught by spam filters more than email sent from other large senders.
1. **No Monkey Patching or Subclassing**: The Messaging class (and all other built in classes) can't be monkey patched or subclassed to give them additional functionality, and the built in syntax is a bit ugly.

This custom object and set of classes leverage Amazon Web Services' Simple Email Service to remove the email limits and create a more extensible email framework.

AWS SES email costs only $0.10 per 1,000, so almost any transaction email requirement can be accomplished for very little cost.

Simple Example
==============
Now you can send email with a single line:
<pre>
new Email('test@test.com','Test Email Subject','This is the test email body.').send();
</pre>

...or directly to a contact:

<pre>
Contact c = new Contact(firstName = 'Sean', lastName = 'Devine', email='test@test.com');
upsert c;
new Email(c, 'Test Email Subject','This is the test email body.').send();
</pre>

...or use VisualForce pages for the email body and control the to, cc, bcc and reply-to lists.
<pre>
  PageReference emailPage = new PageReference('/apex/examplepage');
  emailPage.setRedirect(true);
  Email e = new Email();
  e.htmlBody = emailPage.getContent().toString();
  e.subject = 'Example Email Subject';
  e.addToAddress('test@test.com');
  e.addCCAddresses(new String[]{'testtoo@test.com','testthree@test.com'});
  e.addReplyToAddress('testreply@test.com');
  e.send();
</pre>
... or change the class to behave however you'd like it to.

Installation Instructions
=========================
Installing open source software in the force.com platform isn't as easy as it could be, so you'll have to do a little bit of work.

1. Sign up for [Amazon Web Services](http://aws.amazon.com/) and its [Simple Email Service](http://aws.amazon.com/ses/).

1. Create an `Email__c` sObject that matches the `src/objects/Email__c.object` spec.

1. Create the classes in the `src/classes` folder. If you have any class name clashes with your org, make the appropriate modification. The `StringUtils` and `ArrayUtils` classes are subsets/simplifications of the [apex-commons](https://github.com/apex-commons) library.

1. Modify the `AWS.KEY` AND `AWS.SECRET` constants to match the key and secret of your AWS account.

1. Modify the `Email.DEF_FROM_ADDRESS` constant to the default email from address for your organization. Note that you can set the reply to for each email separately so that you do not have to register too many sending addresses with AWS.

1. Add a remote site setting for AWS at `Setup > Security Controls > Remote Site Settings` and add your AWS endpoint. This should match the `Email.ENDPOINT` constant (`https://email.us-east-1.amazonaws.com` in this default setup).

Nice Features
=============
- Emails are sent synchronously if there are no pending commits (which would prevent callouts) and if there is callout capacity available. Otherwise, the emails are queued to be sent in batch.
- Both HTML and plain body emails are supported. You can send emails that are larger than the long text fields can support because the class uses attachments to store HTML bodies.

Missing Features
================
- Email attachments are not currently supported by these classes. AWS supports them for most file types now (see the [Sending Raw Email MIME documentation](http://docs.amazonwebservices.com/ses/latest/DeveloperGuide/SendingEmail.Raw.html) for more info). If someone has time to implement MIME functionality, it would be a great addition.
- Emails cannot be sent from Batch apex if there are any pending commits (batches cannot be scheduled from batch executes). This could be solved by exposing a web service in the Email class and using a proxy server to call it from a batch execute, but that hasn't been written.
- The same attachment-backed approach should be used for plain bodies as well. That would enable larger plain text emails to be sent and would make the approach consistent.
- The HTML detection couldn't be more basic, but it didn't seem like a big priority.