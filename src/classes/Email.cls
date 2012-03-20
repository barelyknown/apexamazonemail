global class Email implements Schedulable, Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

  public static final String DEF_FROM_ADDRESS = Email.getPrettyEmail('YOUR NAME', 'YOUR_EMAIL@YOUR_EMAIL.COM');
  public static final String SOBJ_NAME = 'email__c';
  public static final String ALL_UNSENT_WHERE_CLAUSE = 'is_sent__c = false and has_error__c = false';
    
  public Email(Boolean isBatch) {
    this(true, null, null, null, null);
  }

  public Email() {
    this(new Email__c());
  }
  
  public Email(Email__c sobj) {
    this(false, sobj, null, null, null);
  }
  
  public Email(Contact toContact, String subject, String body) {
    this(Email.getPrettyEmail(toContact), subject, body);
  }
  
  public Email(Contact[] toContacts, String subject, String body) {
    this(Email.getPrettyEmails(toContacts), subject, body);
  }
  
  public Email(String toAddress, String subject, String body) {
    this(false, new Email__c(), new String[]{toAddress}, subject, body);
  }
  
  public Email(String[] toAddresses, String subject, String body) {
    this(false, new Email__c(), toAddresses, subject, body);
  }
  
  public Email(Boolean isBatch, Email__c sobj, String[] toAddresses, String subject, String body) {
    if (!isBatch) {
      this.sobj = sobj;
      if (toAddresses != null) {
        addToAddresses(toAddresses);
      }
      if (subject != null) {
        this.subject = subject;
      }
      if (body != null) {
        if (isHtml(body)) {
          this.htmlBody = body;
        } else {
          this.plainBody = body;
        }        
      }
      if (fromAddress == null) {
        fromAddress = DEF_FROM_ADDRESS;
      }
      if (replyToAddresses.size() == 0) {
        addReplyToAddress(Email.getPrettyEmail((Id)UserInfo.getUserId()));      
      }
    }
  }
  
  private Boolean isHtml(String body) {
    return (body.contains('HTML') || body.contains('html'));
  }
  
  global void execute(SchedulableContext sc) {
    Database.executeBatch(new Email(), 1);
	}
	
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(getSoqlWhere(Email.ALL_UNSENT_WHERE_CLAUSE));
  }
  
  global void execute(Database.BatchableContext bc, Email__c[] sobjs) {
    Email[] emails = Email.getEmails(sobjs);
    Email.sendAll(emails, false);
  }

  global void finish(Database.BatchableContext bc) {
  }
  
  private Email__c sobj {
    get;
    set;
  }

  public Id emailId {
    get {
      return sobj.id;
    }
  }
  
  public String name {
    get {
      return sobj.name;
    }
  }
  
  public String subject {
    get {
      return this.sobj.subject__c;
    }
    set {
      this.sobj.subject__c = value;
    }
  }
  
  public String plainBody {
    get {
      return this.sobj.plain_body__c;
    }
    set {
      this.sobj.plain_body__c = value;
    }
  }
  
  public String htmlBody {
    get {
      if (bodyDocument.body == null) {
        return null;
      }
      return bodyDocument.body.toString();
    }
    set {
      bodyDocument.body = Blob.valueOf(value);
    }
  }
  
  public Id bodyDocumentId {
    get {
      return this.sobj.body_document_id__c;
    }
    set {
      this.sobj.body_document_id__c = value;
    }
  }
  
  private Attachment bodyDocument {
    get {
      if (sobj.body_document_id__c == null && bodyDocument == null) {
        bodyDocument = new Attachment(name = 'email_body.html');
      } else if (bodyDocument == null) {
        bodyDocument = [select id, parentId, name, body from attachment where id = :bodyDocumentId];
      }
      return bodyDocument;
    }
    set;
  }
  
  public void addToAddress(String toAddress) {
    toAddresses = (String[])ArrayUtils.add(toAddresses, toAddress);
  }
  
  public void addToAddresses(String[] moreToAddresses) {
    toAddresses = (String[])ArrayUtils.addAll(toAddresses, moreToAddresses);
  }
  
  private String[] toAddresses {
    get {
      if (this.sobj.to_addresses__c == null) {
        return new String[]{};
      }
      return (String[])JSON.deserialize(this.sobj.to_addresses__c, String[].class);
    }
    set {
      this.sobj.to_addresses__c = JSON.serialize(value);
    }
  }
  
  public void addCCAddress(String ccAddress) {
    ccAddresses = (String[])ArrayUtils.add(ccAddresses, ccAddress);
  }
  
  public void addCCAddresses(String[] moreCCAddresses) {
    ccAddresses = (String[])ArrayUtils.addAll(ccAddresses, moreCCAddresses);
  }  
  
  public String[] ccAddresses {
    get {
      if (this.sobj.cc_addresses__c == null) {
        return new String[]{};
      }
      return (String[])JSON.deserialize(this.sobj.cc_addresses__c, String[].class);
    }
    set {
      this.sobj.cc_addresses__c = JSON.serialize(value);
    }
  }
  
  public String[] bccAddresses {
    get {
      if (this.sobj.bcc_addresses__c == null) {
        return new String[]{};
      }
      return (String[])JSON.deserialize(this.sobj.bcc_addresses__c, String[].class);
    }
    set {
      this.sobj.bcc_addresses__c = JSON.serialize(value);
    }
  }
  
  public String fromAddress {
    get {
      return this.sobj.from_address__c;
    }
    set {
      this.sobj.from_address__c = value;
    }
  }
  
  public void addReplyToAddress(String replyToAddress) {
    replyToAddresses = (String[])ArrayUtils.add(replyToAddresses, replyToAddress);
  }
  
  public void addReplyToAddresses(String[] moreReplyToAddresses) {
    replyToAddresses = (String[])ArrayUtils.addAll(replyToAddresses, moreReplyToAddresses);
  }
  
  public String[] replyToAddresses {
    get {
      if (this.sobj.reply_to_addresses__c == null) {
        return new String[]{};
      }
      return (String[])JSON.deserialize(this.sobj.reply_to_addresses__c, String[].class);
    }
    set {
      this.sobj.reply_to_addresses__c = JSON.serialize(value);
    }
  }
  
  public String returnAddress {
    get {
      return this.sobj.return_address__c;
    }
    set {
      this.sobj.return_address__c = value;
    }
  }
  
  public String sendResponse {
    get {
      return this.sobj.send_response__c;
    }
    set {
      this.sobj.send_response__c = value;
    }
  }
  
  public Boolean isSent {
    get {
      return this.sobj.is_sent__c;
    }
    set {
      this.sobj.is_sent__c = value;
    }
  }
  
  public Boolean hasError {
    get {
      return this.sobj.has_error__c;
    }
    set {
      this.sobj.has_error__c = value;
    }
  }
  
  public Email save() {
    try {
      upsert this.sobj;
    } catch (Exception e) {
      if (ApexPages.currentPage() != null) {
        ApexPages.addMessages(e);
      }
    }
    return this;
  }
  
  public void del() {
    try {
      delete this.sobj;
    } catch (Exception e) {
      if (ApexPages.currentPage() != null) {
        ApexPages.addMessages(e);
      }
    }
  }
  

	public String amazonSimpleEmail {
	  get {
  		String amazonEncoded = 'Action=SendEmail';
  		amazonEncoded += '&Source='+EncodingUtil.urlEncode(this.fromAddress,'UTF-8');
  		for (Integer i=1; i <= this.toAddresses.size(); i++) {
  			amazonEncoded += '&Destination.ToAddresses.member.' + i + '=' + EncodingUtil.urlEncode(this.toAddresses[i-1],'UTF-8');
  		}
  		for (Integer i = 1; i <= this.ccAddresses.size(); i++) {
  		  amazonEncoded += '&Destination.CcAddresses.member.' + i + '=' + EncodingUtil.urlEncode(this.ccAddresses[i-1],'UTF-8');
  		}
  		for (Integer i = 1; i <= this.replyToAddresses.size(); i++) {
  		  amazonEncoded += '&ReplyToAddresses.member.' + i + '=' + EncodingUtil.urlEncode(this.replyToAddresses[i-1],'UTF-8');
  		} 
  		amazonEncoded += '&Message.Subject.Data=' + EncodingUtil.urlEncode(this.subject,'UTF-8');
  		if (this.plainBody != null) {
  		  amazonEncoded += '&Message.Body.Text.Data=' + EncodingUtil.urlEncode(this.plainBody, 'UTF-8');
  		}
  		if (this.htmlBody != null) {
  		  amazonEncoded += '&Message.Body.Html.Data=' + EncodingUtil.urlEncode(this.htmlBody,'UTF-8');
  		}
  		return amazonEncoded;	    
	  }
	}

  public void send() {
    Email.sendAll(new Email[]{this}, true);
  }
  
  public static void sendAll() {
    sendAll(findWhere(ALL_UNSENT_WHERE_CLAUSE), true);
  }
  
  public static void sendAll(Email[] emails, Boolean batchRemaining) {
    SES simpleEmailService = new SES();
    Boolean batchCallRequired = false;
    for (Email e: emails) {
      if (Limits.getLimitCallouts() - Limits.getCallouts() > 0 && Limits.getDmlStatements() == 0) {
        HttpResponse response = simpleEmailService.sendSimpleEmail(e.amazonSimpleEmail);
        e.sendResponse = response.getBody();
        if (response.getStatusCode() != 200) {
          e.hasError = true;
        } else {
          e.hasError = false;
          e.isSent = true;
        }
      } else {
        if (batchRemaining) {
          batchCallRequired = true;
        }
      }
    }
    upsert getSobjs(emails);
    Attachment[] documents = new Attachment[]{};
    for (Email e: emails) {
      e.bodyDocument.parentId = e.sobj.id;
      if (e.bodyDocument.body != null) {
        documents.add(e.bodyDocument);
      }
    }
    if (documents.size() > 0) {
      upsert documents;
    }
    for (Email e: emails) {
      if (e.bodyDocument.id != null) {
        e.sobj.body_document_id__c = e.bodyDocument.id;
      }
    }
    upsert getSobjs(emails);
    if (batchCallRequired) {
      Database.executeBatch(new Email(true), 1);
    }
  }
  
  public static Email__c[] getSobjs(Email[] emails) {
    Email__c[] sobjs = new Email__c[]{};
    for (Email email: emails) {
      sobjs.add(email.sobj);
    }
    return sobjs;
  }

  public static Email[] getEmails(Email__c[] sobjs) {
    Email[] emails = new Email[]{};
    for (Email__c sobj: sobjs) {
      emails.add(new Email(sobj));
    }
    return emails;
  }
  
  public static String getSoqlWhere(String soqlWhere) {
    String soqlSelect = 'select ' + StringUtils.joinSet(Schema.getGlobalDescribe().get('email__c').getDescribe().fields.getMap().keySet(),', ');
    soqlSelect += ' from ' + SOBJ_NAME;
    if (soqlWhere != null) {
      soqlSelect += ' where ' + soqlWhere;
    }
    return soqlSelect;    
  }
  
  public static Email[] findWhere(String soqlWhere) {
    Email__c[] sobjs = new Email__c[]{};
    try {
      sobjs = Database.query(getSoqlWhere(soqlWhere));
    } catch (Exception e) {
      System.debug(e);
    }
    return getEmails(sobjs);
  }
  
  public static String getPrettyEmail(Id userId) {
    User user = [select name, email from user where id = :userId limit 1];
    return getPrettyEmail(user);
  }

  public static String getPrettyEmail(User user) {
    return getPrettyEmail(user.name, user.email);
  }

  public static String getPrettyEmail(Contact ctc) {
    Contact c = [select name, email from contact where id = :ctc.id];
    return getPrettyEmail(c.name, c.email);
  }

  public static String getPrettyEmail(String name, String email) {
    return name + ' <' + email + '>';
  }
  
  public static String[] getPrettyEmails(Contact[] contacts) {
    String[] prettyEmails = new String[]{};
    for (Contact c: contacts) {
      prettyEmails.add(getPrettyEmail(c));
    }
    return prettyEmails;
  }
    
}