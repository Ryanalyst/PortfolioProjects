import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class Calculator implements ActionListener{

	JFrame frame;
	JTextField textfield;
	JButton[] numberButtons = new JButton[10];
	JButton[] functionButtons = new JButton[9];
	JButton addButton, subButton, mulButton, divButton;
	JButton decButton, equButton, delButton, clrButton, negButton;
	JPanel panel;
	
	Font myFont = new Font("Ink Free",Font.BOLD,30);
	
	double num1 = 0, num2 = 0, result = 0;
	char operator;
	
	Calculator(){
		//creating the name for the calculator
		frame = new JFrame("Calculator");
		//Deciding what the program should do when x button is clicked at the top right
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		//Setting window width and height
		frame.setSize(420,550);
		frame.setLayout(null);
		
		//Creating a textfield that the user can type in
		textfield = new JTextField();
		//Location of the textfield(x, y, width, height of the field)
		textfield.setBounds(50, 25, 300, 50);
		//Font you wish to use for the text. We can use the font we created earlier
		textfield.setFont(myFont);
		//Sets the textfield so that you can't type anything into it. Useful in this 
		//instance because we want the input to come from buttons, not the user.
		textfield.setEditable(false);
		
		//Instantiating our buttons that we declared earlier and giving them an icon to display
		addButton = new JButton("+");
		subButton = new JButton("-");
		mulButton = new JButton("*");
		divButton = new JButton("/");
		decButton = new JButton(".");
		equButton = new JButton("=");
		delButton = new JButton("Delete");
		clrButton = new JButton("Clear");
		negButton = new JButton("(-)");
		
		//Adds the buttons to our function button array we created
		functionButtons[0] = addButton;
		functionButtons[1] = subButton;
		functionButtons[2] = mulButton;
		functionButtons[3] = divButton;
		functionButtons[4] = decButton;
		functionButtons[5] = equButton;
		functionButtons[6] = delButton;
		functionButtons[7] = clrButton;
		functionButtons[8] = negButton;


		for(int i = 0; i < 9; i++) {
			functionButtons[i].addActionListener(this);
			//sets the font of each button
			functionButtons[i].setFont(myFont);
			//This makes it so an outline won't appear around a button when we press it
			functionButtons[i].setFocusable(false);
		}
		
		for(int i = 0; i < 10; i++) {
			//instantiates the buttons for our numbers. You could do it the way we did for 
			//our functions, but this is quicker. The loop will go through each button in
			//our array and then assign them with an icon of numbers 0-9
			numberButtons[i] = new JButton(String.valueOf(i));
			numberButtons[i].addActionListener(this);
			numberButtons[i].setFont(myFont);
			numberButtons[i].setFocusable(false);
		}

		//Sets the location for the negButton, delButton and clrButton at a specific part of our 
		//window (x, y, width and height of button. The width and height are in pixels)
		negButton.setBounds(50,430,75,50);
		delButton.setBounds(125,430,125,50);
		clrButton.setBounds(235,430,115,50);

		//instantiates the panel that we declared at the start of the program
		panel = new JPanel();
		panel.setBounds(50,100,300,300);
		//Sets the layout of our panel, the first two numbers are how many rows & columns you want
		//and the next two are how many pixels you want between each button (width, height)
		panel.setLayout(new GridLayout(4,4,10,10));
		//Sets the bg color of our panel
		panel.setBackground(Color.gray);
		
		//creates the first row of buttons on our panel. 
		panel.add(numberButtons[1]);
		panel.add(numberButtons[2]);
		panel.add(numberButtons[3]);
		panel.add(addButton);
		//creates the 2nd row
		panel.add(numberButtons[4]);
		panel.add(numberButtons[5]);
		panel.add(numberButtons[6]);
		panel.add(subButton);
		//creates the 3rd row
		panel.add(numberButtons[7]);
		panel.add(numberButtons[8]);
		panel.add(numberButtons[9]);
		panel.add(mulButton);
		//creates the final row.
		panel.add(decButton);
		panel.add(numberButtons[0]);
		panel.add(equButton);
		panel.add(divButton);



		
		//adds the panel to our window
		frame.add(panel);				
		//Adds the negative, delete, and clear buttons at the bottom to our window
		frame.add(delButton);
		frame.add(clrButton);
		frame.add(negButton);
		//Adds the textfield we created to the window. You want to do this only after you've
		//created all of the buttons and added them to your window
		frame.add(textfield);
		frame.setVisible(true);
		
	}
	
	public static void main(String[] args) {
		
		Calculator calc = new Calculator();

	}
	/*This method is responsible for what happens when we click on each button. The actionPerformed
	  method is an abstract method found in the actionListener class that we added to our 
	  calculator class when we typed in implements ActionListener.*/
	
	//@Override
	public void actionPerformed(ActionEvent e) {
		//The action event in question is when we click on the screen. The if statement is saying
		//if the space we clicked at is a button in our number button array, then add that number
		//to the front of our text field.
		for(int i = 0; i < 10; i++) {
			if(e.getSource() == numberButtons[i]) {
				textfield.setText(textfield.getText().concat(String.valueOf(i)));
			}
		}
		//If the part of the screen we clicked is the decButton, the add a decimal to the front
		if(e.getSource()==decButton) {
			textfield.setText(textfield.getText().concat("."));
		}
		/*If the button we click is the addButton, instantiate the num1 variable with whatever
		text is currently in our textfield and then converts it from string to a double.
		It then sets our operator variable to + which we will use when returning the final result.
		Lastly, we clear the text field so that we can input a new number. The next 
		3 if statements work similarly, except we use them to subtract, multiply, and divide.*/
		try {
		if(e.getSource() == addButton) {
			num1 = Double.parseDouble(textfield.getText());
			operator = '+';
			textfield.setText("");
		}
		if(e.getSource() == subButton) {
			num1 = Double.parseDouble(textfield.getText());
			operator = '-';
			textfield.setText("");
		}
		if(e.getSource() == mulButton) {
			num1 = Double.parseDouble(textfield.getText());
			operator = '*';
			textfield.setText("");
		}
		if(e.getSource() == divButton) {
			num1 = Double.parseDouble(textfield.getText());
			operator = '/';
			textfield.setText("");
		}
		/*I added a try-catch block around the if statements, that way if the user accidentally clicks
		a non-number button while the text field is empty, it will print out an error message. These
		if statements are what is used to store the calculated result of past operations and adds
		functionality to the +,-,*,/ buttons*/

		if(e.getSource() == equButton) {
			num2 = Double.parseDouble(textfield.getText());
			
			switch(operator) {
			case '+':
				result = num1 + num2;
				break;
			case '-':
				result = num1 - num2;
				break;
			case '*':
				result = num1 * num2;
				break;
			case '/':
				result = num1 / num2;
				break;
			}
			textfield.setText(String.valueOf(result));
			num1 = result;
		}
		if(e.getSource() == negButton) {
			double temp = Double.parseDouble(textfield.getText());
			temp *= -1;
			textfield.setText(String.valueOf(temp));			
		}
		}catch(Exception exception) {
			System.out.println("Error: No number found, input number first");
		} 
		if(e.getSource() == clrButton) {
			textfield.setText("");
		}
		if(e.getSource() == delButton) {
			String string = textfield.getText();
			textfield.setText("");
			for(int i = 0; i < string.length() - 1; i++) {
				textfield.setText(textfield.getText()+string.charAt(i));
			}
		}

	}

}
