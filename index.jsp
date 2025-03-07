<%@ page import="java.sql.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.util.*" %>

<html>
<head>
	<title>Email Subscription</title>
    	<style>
        body {
            	background: linear-gradient(to right, #FFDAB9, #E9967A); /* Peach to Dark Salmon gradient */
            	color: #333;
            	font-family: Tahoma, sans-serif;
            	margin: 0;
            	padding: 0;
            	display: flex;
            	align-items: flex-start; /* Align items to the top */
            	justify-content: center;
            	height: 100vh; /* Full viewport height */
       	 	}
        .container {
            	margin-top: 30px; /* Top margin to space from the very top */
            	text-align: center;
            	width: 100%;
            	max-width: 600px;
        	}
        h1 {
           	background: #FF4500; /* Orange Red */
            	color: #fff;
            	padding: 20px 40px; /* Vertical and horizontal padding */
            	border-radius: 10px;
            	box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
            	margin-bottom: 30px;
            	font-size: 36px;
        	}
        form {
            	background: #FFE4E1; /* Misty Rose */
            	padding: 30px;
            	border-radius: 10px;
            	display: flex;
            	flex-direction: column;
            	align-items: center;
            	box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
        	}
        input[type=email] {
            	margin: 10px 0;
            	padding: 15px;
            	border: none;
            	border-radius: 5px;
            	width: calc(100% - 32px); /* Full width minus padding */
            	font-size: 18px;
            	box-sizing: border-box; /* Includes padding in width calculation */
        	}
        input[type=radio] {
            	margin-right: 10px;
            	transform: scale(1.5); /* Larger radio buttons */
            	vertical-align: middle;
        	}
        label {
            	display: block;
            	margin: 10px 0;
            	font-size: 22px; /* Larger text for labels */
        	}
        input[type=submit] {
            	background: #FF6347; /* Tomato */
            	color: #fff;
            	cursor: pointer;
            	font-size: 18px; /* Font size for button */
            	padding: 12px 25px; /* Padding for button */
            	border: none;
            	border-radius: 5px;
            	margin-top: 20px;
        	}
        input[type=submit]:hover {
            	background: #FF4500; /* Orange Red */
        	}
        .message {
            	margin-top: 20px;
            	font-size: 24px; /* Larger text for output message */
            	color: #FF4500; /* Orange Red */
            	font-weight: bold;
        	}
    </style>
<link rel = "icon" href = "msg.ico"/>
</head>
<body>
	<div class="container">
        	<h1>Email Subscription</h1>
        	<form method="post">
            		<input type="email" name="email" placeholder="Enter your email" required />
            		<label><input type="radio" name="subscription" value="subscribe" required /> Subscribe</label>
            		<label><input type="radio" name="subscription" value="unsubscribe" required /> Unsubscribe</label>
            		<input type="submit" name="btn" value="Submit" />
        	</form>

        <%
        if (request.getParameter("btn") != null) {
		String email = request.getParameter("email");
            	String subscription = request.getParameter("subscription");
            	String message = "";

            	// Validate email format
            	if (!email.matches("^[\\w.-]+@[\\w.-]+\\.\\w{2,}$")) {
                	message = "Invalid email format. Please enter a valid email address.";
            	} else {
                	// Database connection setup
                	Connection conn = null;
                	PreparedStatement stmt = null;
                	ResultSet rs = null;

                	try {
                    	// Load JDBC driver
                    	Class.forName("com.mysql.cj.jdbc.Driver");
                    	// Connect to the database
                    	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/emailapp", "root", "abc456");

                    	// Check if the email already exists in the database
                    	String checkSQL = "SELECT email FROM subscribers WHERE email = ?";
                    	stmt = conn.prepareStatement(checkSQL);
                    	stmt.setString(1, email);
                    	rs = stmt.executeQuery();

                    	if ("subscribe".equals(subscription)) {
                        	if (rs.next()) {
                            		message = "You are already subscribed.";
                        	} else {
                            		String insertSQL = "INSERT INTO subscribers (email) VALUES (?)";
                            		stmt = conn.prepareStatement(insertSQL);
                            		stmt.setString(1, email);
                            		int rowsAffected = stmt.executeUpdate();
                            		if (rowsAffected > 0) {
                                		message = "You have successfully subscribed!";

                                		// Send email notification
                                		Properties p = System.getProperties();
                                		p.put("mail.smtp.host", "smtp.gmail.com");
                                		p.put("mail.smtp.port", 587);
                                		p.put("mail.smtp.auth", true);
                                		p.put("mail.smtp.starttls.enable", true);

                                		Session ms = Session.getInstance(p, new Authenticator() {
                                    			public PasswordAuthentication getPasswordAuthentication() {
                                        			return new PasswordAuthentication("rbirajdar010@gmail.com", "xkwjcfokrexsuyox");
                                    			}
                                		});

                                		MimeMessage msg = new MimeMessage(ms);
                                		String subject = "Subscription Update";
                                		msg.setSubject(subject);
                                		String txt = "Email: " + email + "\nSubscription: " + subscription + "d successfully";
                                		msg.setText(txt);
                                		msg.setFrom(new InternetAddress("rbirajdar010@gmail.com"));
                                		msg.addRecipient(Message.RecipientType.TO, new InternetAddress("rbirajdar010@gmail.com"));
                                		Transport.send(msg);
                            		} else {
                                		message = "Subscription failed. Please try again.";
                            		}
                        	}
                    	} else if ("unsubscribe".equals(subscription)) {
                        	if (rs.next()) {
                            		String deleteSQL = "DELETE FROM subscribers WHERE email = ?";
                            		stmt = conn.prepareStatement(deleteSQL);
                            		stmt.setString(1, email);
                            		int rowsAffected = stmt.executeUpdate();
                            		if (rowsAffected > 0) {
                                		message = "You have successfully unsubscribed!";

                                		// Send email notification
                                		Properties p = System.getProperties();
                                		p.put("mail.smtp.host", "smtp.gmail.com");
                                		p.put("mail.smtp.port", 587);
                                		p.put("mail.smtp.auth", true);
                                		p.put("mail.smtp.starttls.enable", true);

                                		Session ms = Session.getInstance(p, new Authenticator() {
                                    			public PasswordAuthentication getPasswordAuthentication() {
                                        			return new PasswordAuthentication("rbirajdar010@gmail.com", "xkwjcfokrexsuyox");
                                    			}
                                		});

                                		MimeMessage msg = new MimeMessage(ms);
                                		String subject = "Subscription Update";
                                		msg.setSubject(subject);
                                		String txt = "Email: " + email + "\nSubscription: " + subscription + "d successfully";
                                		msg.setText(txt);
                                		msg.setFrom(new InternetAddress("rbirajdar010@gmail.com"));
                                		msg.addRecipient(Message.RecipientType.TO, new InternetAddress("rbirajdar010@gmail.com"));
                                		Transport.send(msg);
                            		} else {
                                		message = "Unsubscription failed. Please try again.";
                            		}
                        	} else {
                            		message = "You are not subscribed.";
                        	}
                    	}

                	} catch (Exception e) {
                    		message = "Error: " + e.getMessage();
                	} finally {
                    	try {
                        	if (rs != null) rs.close();
                        	if (stmt != null) stmt.close();
                        	if (conn != null) conn.close();
                    	} catch (SQLException e) {
                        	message = "Error closing resources: " + e.getMessage();
                    	}
                	}
            	}

            	out.println("<div class='message'>" + message + "</div>");
        }
        %>
    </div>
</body>
</html>
