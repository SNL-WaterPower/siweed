/**
 * This code is copyright (c) Mathias Markl 2015
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

package at.mukprojects.console;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;

import org.apache.log4j.Appender;
import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.WriterAppender;
import org.slf4j.LoggerFactory;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PFont;

/**
 * This class represents the console. It handles starting and stopping it as
 * well as drawing it to the screen. The console can be started and stopped at
 * any time. For drawing there are multiple different options to render the
 * console.
 *
 * @example DefaultConsole.pde
 * @example CustomConsole.pde
 *
 * @author Mathias Markl
 */
public class Console {

    /**
     * Default font of the console.
     */
    private static final String DEFAULT_FONT = "font.ttf";

    /**
     * Default preferred text size.
     */
    public static final float DEFAULT_PREFERRED_TEXT_SIZE = 14f;

    /**
     * Default minimal text size.
     */
    public static final float DEFAULT_MIN_TEXT_SIZE = 12.5f;

    /**
     * Default line space.
     */
    public static final float DEFAULT_LINE_SPACE = 2f;

    /**
     * Default text padding.
     */
    public static final float DEFAULT_PADDING = 4f;

    /**
     * Default console stroke color.
     */
    public static final int DEFAULT_STROKE_COLOR = 200;

    /**
     * Default console background color.
     */
    public static final int DEFAULT_BACKGROUND_COLOR = 0;

    /**
     * Default text color.
     */
    public static final int DEFAULT_TEXT_COLOR = 200;

    /**
     * Logger Settings
     */
    private static final String PATTERN = "%5p (%c) - %m%n";
    private static final String DEFAULT_APPENDER = "DefaultConsoleAppender";

    private static final org.slf4j.Logger logger = LoggerFactory.getLogger(Console.class);

    private PApplet applet;

    private PrintStream originalSystemOut;
    private ByteArrayOutputStream byteStream;
    private PrintStream printStream;
    private WriterAppender appender;

    private boolean started;

    private PFont consoleFont;

    private String input;
    private List<String> renderList;

    private boolean timestamp;
    private boolean cutMove;
    private boolean autoPrint;

    private SimpleDateFormat timestampFormat;

    /**
     * Constructs a new Console object.
     * 
     * @param applet
     *            The processing sketch.
     */
    public Console(PApplet applet) {
	this(applet, applet.createFont(DEFAULT_FONT, DEFAULT_MIN_TEXT_SIZE));
    }

    /**
     * Constructs a new Console object.
     * 
     * @param applet
     *            The processing sketch.
     * @param font
     *            The font of the console.
     */
    public Console(PApplet applet, PFont font) {
	this.applet = applet;
	this.consoleFont = font;

	timestampFormat = new SimpleDateFormat("MM/dd - HH:mm:ss");
	originalSystemOut = System.out;

	started = false;

	timestamp = false;
	cutMove = false;
	autoPrint = false;

	/*
	 * Logger configuration
	 */
	if (!Logger.getRootLogger().getAllAppenders().hasMoreElements()) {
	    Logger.getRootLogger().setLevel(Level.DEBUG);

	    ConsoleAppender appender = new ConsoleAppender(new PatternLayout(PATTERN));
	    appender.setName(DEFAULT_APPENDER);
	    Logger.getRootLogger().addAppender(appender);
	}
    }

    /**
     * If timestamp is set to true, the console will add a timestamp to every
     * log entry.
     * 
     * @param timestamp
     *            The timestamp flag.
     */
    public void setTimestamp(boolean timestamp) {
	this.timestamp = timestamp;
    }

    /**
     * If this flag is set to true, the console will cut log entries which
     * include the String "__MOVE__". This String gets printed everytime the the
     * Processing window is moved.
     * 
     * @param cutMove
     *            The flag.
     */
    public void setCutMove(boolean cutMove) {
	this.cutMove = cutMove;
    }

    /**
     * If this flag is set to true, the Console will also be printed to the
     * default system out.
     * 
     * @param autoPrint
     *            The flag.
     */
    public void setAutoPrint(boolean autoPrint) {
	this.autoPrint = autoPrint;
    }

    /**
     * Starts the console. The standard output and error stream will be
     * redirected to the console.
     */
    public void start() {
	if (started) {
	    logger.info("Console is already running.");
	} else {
	    logger.info("Console is starting...");

	    byteStream = new ByteArrayOutputStream();
	    printStream = new PrintStream(byteStream);

	    System.setOut(printStream);
	    System.setErr(printStream);

	    appender = new WriterAppender(new PatternLayout(PATTERN), printStream);
	    Logger.getRootLogger().addAppender(appender);

	    started = true;

	    input = "";
	    renderList = new ArrayList<>();

	    logger.info("Console has started.");
	    logger.info("The standard output and error stream is redirected to the console.");
	}
    }

    /**
     * Checks if more than one ConsoleAppender is added to the Logger. If so,
     * the default ConsoleAppender will be removed.
     */
    public void checkDuplicateAppender() {
	List<ConsoleAppender> consoleAppenders = new ArrayList<ConsoleAppender>();
	Enumeration<?> e = Logger.getRootLogger().getAllAppenders();

	while (e.hasMoreElements()) {
	    Appender appender = (Appender) e.nextElement();
	    if (appender instanceof ConsoleAppender) {
		consoleAppenders.add((ConsoleAppender) appender);
	    }
	}

	if (consoleAppenders.size() >= 2) {
	    logger.info("Multiple ConsoleAppenders! Default ConsoleAppender will be removed.");

	    Logger.getRootLogger().removeAppender(DEFAULT_APPENDER);
	}
    }

    /**
     * Stops the console. The standard output and error stream will be set back
     * to the original system output.
     */
    public void stop() {
	logger.info("Console is stopping...");

	Logger.getRootLogger().removeAppender(appender);

	System.setOut(originalSystemOut);
	System.setErr(originalSystemOut);

	if (byteStream != null && printStream != null) {
	    try {
		byteStream.close();
		printStream.close();
	    } catch (IOException exception) {
		logger.error(exception.getMessage(), exception);
	    }
	}

	started = false;

	logger.info("Console has stoped.");
    }

    /**
     * Prints the stream to the original system output.
     */
    public void print() {
	String completeInput = byteStream.toString();

	if (input.isEmpty()) {
	    originalSystemOut.print(completeInput);
	} else {
	    if (input.length() <= completeInput.length()) {
		originalSystemOut.print(completeInput.substring(input.length()));
	    } else {
		logger.error("An error occurred while printing the input.");
	    }
	}

	input = completeInput;
    }

    /**
     * Draws the console to the screen.
     */
    public void draw() {
	draw(0, applet.height - 120, applet.width, applet.height, DEFAULT_PREFERRED_TEXT_SIZE, DEFAULT_MIN_TEXT_SIZE,
		DEFAULT_LINE_SPACE, DEFAULT_PADDING, DEFAULT_STROKE_COLOR, DEFAULT_BACKGROUND_COLOR,
		DEFAULT_TEXT_COLOR);
    }

    /**
     * Draws the console to the screen.
     * 
     * @param x
     *            The x position of the console.
     * @param y
     *            The y position of the console.
     * @param width
     *            The width of the console.
     * @param height
     *            The height of the console.
     */
    public void draw(float x, float y, float width, float height) {
	draw(x, y, width, height, DEFAULT_PREFERRED_TEXT_SIZE, DEFAULT_MIN_TEXT_SIZE, DEFAULT_LINE_SPACE,
		DEFAULT_PADDING, DEFAULT_STROKE_COLOR, DEFAULT_BACKGROUND_COLOR, DEFAULT_TEXT_COLOR);
    }

    /**
     * Draws the console to the screen.
     * 
     * @param x
     *            The x position of the console.
     * @param y
     *            The y position of the console.
     * @param width
     *            The width of the console.
     * @param height
     *            The height of the console.
     * @param preferredTextSize
     *            The preferred text size.
     * @param minTextSize
     *            The minimum text size.
     */
    public void draw(float x, float y, float width, float height, float preferredTextSize, float minTextSize) {
	draw(x, y, width, height, preferredTextSize, minTextSize, DEFAULT_LINE_SPACE, DEFAULT_PADDING,
		DEFAULT_STROKE_COLOR, DEFAULT_BACKGROUND_COLOR, DEFAULT_TEXT_COLOR);
    }

    /**
     * Draws the console to the screen.
     * 
     * @param x
     *            The x position of the console.
     * @param y
     *            The y position of the console.
     * @param width
     *            The width of the console.
     * @param height
     *            The height of the console.
     * @param preferredTextSize
     *            The preferred text size.
     * @param minTextSize
     *            The minimum text size.
     * @param lineSpace
     *            The space between the lines.
     * @param padding
     *            The padding of the text.
     */
    public void draw(float x, float y, float width, float height, float preferredTextSize, float minTextSize,
	    float lineSpace, float padding) {
	draw(x, y, width, height, preferredTextSize, minTextSize, lineSpace, padding, DEFAULT_STROKE_COLOR,
		DEFAULT_BACKGROUND_COLOR, DEFAULT_TEXT_COLOR);
    }

    /**
     * Draws the console to the screen.
     * 
     * @param x
     *            The x position of the console.
     * @param y
     *            The y position of the console.
     * @param width
     *            The width of the console.
     * @param height
     *            The height of the console.
     * @param preferredTextSize
     *            The preferred text size.
     * @param minTextSize
     *            The minimum text size.
     * @param lineSpace
     *            The space between the lines.
     * @param padding
     *            The padding of the text.
     * @param strokeColor
     *            The color of the console stroke.
     * @param consoleColor
     *            The color of the console background.
     * @param textColor
     *            The text color.
     */
    public void draw(float x, float y, float width, float height, float preferredTextSize, float minTextSize,
	    float lineSpace, float padding, int strokeColor, int consoleColor, int textColor) {
	if (started) {
	    render(x, y, width, height, preferredTextSize, minTextSize, lineSpace, padding, strokeColor, consoleColor,
		    textColor);
	    if (autoPrint) {
		print();
	    }
	} else {
	    logger.info("Console isn't running.");
	}
    }

    private void render(float x, float y, float width, float height, float preferredTextSize, float minTextSize,
	    float lineSpace, float padding, int strokeColor, int consoleColor, int textColor) {
	ArrayList<String> preRenderList = new ArrayList<String>();
	String[] textsSplit = PApplet.split(byteStream.toString(), "\n");

	for (int i = 0; i < textsSplit.length; i++) {
	    if (!textsSplit[i].isEmpty()) {
		if (cutMove) {
		    if (!textsSplit[i].contains("__MOVE__")) {
			preRenderList.add(textsSplit[i]);
		    }
		} else {
		    preRenderList.add(textsSplit[i]);
		}
	    }
	}

	for (int i = renderList.size(); i < preRenderList.size(); i++) {
	    String logString = preRenderList.get(i);

	    if (timestamp) {
		logString = "[" + timestampFormat.format(new Date()) + "] " + logString;
	    }
	    renderList.add(logString);
	}

	float size = calculateTextSize(renderList, (width - x) - (2 * padding), preferredTextSize, minTextSize);

	applet.pushMatrix();

	applet.strokeWeight(2);
	applet.stroke(strokeColor);
	applet.fill(consoleColor);
	applet.rect(x, y, width, height);

	applet.textAlign(PConstants.LEFT, PConstants.TOP);
	applet.textFont(consoleFont, size);

	applet.fill(textColor);

	float lineHeight = calculateLineHeight(size, lineSpace);
	int startIndex = calculateStartIndex(renderList, size, (width - x) - (2 * padding), (y + lineSpace + padding),
		lineHeight, height);
	List<String> subRenderList = renderList.subList(startIndex, renderList.size());

	int additionalLines = 0;
	for (int i = 0; i < subRenderList.size(); i++) {
	    int linesTaken = calculateLines(subRenderList.get(i), size, (width - x) - (2 * padding));
	    float yPos = (y + lineSpace + padding) + (i * lineHeight) + (additionalLines * lineHeight);

	    if (linesTaken > 1) {
		additionalLines += linesTaken - 1;
	    }

	    applet.text(subRenderList.get(i), x + padding, yPos, width - padding, yPos + (linesTaken * lineHeight));
	}

	applet.popMatrix();
    }

    private int calculateStartIndex(List<String> renderList, float size, float width, float yStart, float lineHeight,
	    float height) {
	int itemCounter = 0;
	int additionalLines = 0;
	int index = 0;

	for (int i = renderList.size() - 1; i >= 0; i--) {
	    int linesTaken = calculateLines(renderList.get(i), size, width);

	    float yPos = yStart + (itemCounter * lineHeight) + (additionalLines * lineHeight);
	    float calcHeight = yPos + (linesTaken * lineHeight);

	    if (calcHeight > height) {
		index = i + 1;
		break;
	    }

	    if (linesTaken > 1) {
		additionalLines += linesTaken - 1;
	    }

	    itemCounter++;
	}

	return index;
    }

    private float calculateLineHeight(float size, float lineSpace) {
	return applet.textAscent() + applet.textDescent() + lineSpace;
    }

    private int calculateLines(String text, float size, float width) {
	String tempText = "";
	int linesTaken = 1;

	for (int i = 0; i < text.length(); i++) {
	    tempText += text.charAt(i);

	    if (applet.textWidth(tempText) > width) {
		tempText = "c";
		linesTaken++;
	    }
	}

	return linesTaken;
    }

    private float calculateTextSize(List<String> texts, float width, float startingTextSize, float minTextSize) {
	String longestText = null;

	for (int i = 0; i < texts.size(); i++) {
	    if (longestText == null) {
		longestText = texts.get(i);
	    }

	    if (texts.get(i).length() > longestText.length()) {
		longestText = texts.get(i);
	    }
	}

	float textSize = startingTextSize;

	applet.pushMatrix();
	applet.textFont(consoleFont, startingTextSize);

	while (applet.textWidth(longestText) > width) {
	    textSize -= 0.5;

	    if (textSize < minTextSize) {
		break;
	    }
	}

	applet.popMatrix();

	if (textSize < minTextSize) {
	    return minTextSize;
	} else {
	    return textSize;
	}
    }
}
