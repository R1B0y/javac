import java.util.*;
import java.io.*;

public class ParserTest {

a = 123;


    public static void main(String[] args) {
        ParserTest test = new ParserTest();
        test.run();
    }

    public void run() {
        System.out.println("Starting ParserTest...");

        List<String> inputs = Arrays.asList("Hello", "World", null, "Java", "Parser");

        for (String input : inputs) {
            try {
                String processed = processInput(input);
                System.out.println("Processed: " + processed);
            } catch (IllegalArgumentException e) {
                System.err.println("Error processing input: " + e.getMessage());
            }
        }

        Map<String, Integer> counts = countOccurrences(inputs);
        counts.forEach((k, v) -> System.out.println(k + ": " + v));

        NestedClass nested = new NestedClass();
        nested.printMessage();

        AnonymousRunnable anon = new AnonymousRunnable();
        Thread thread = new Thread(anon);
        thread.start();

        try {
            thread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        GenericContainer<Integer> container = new GenericContainer<>(42);
        System.out.println("Generic value: " + container.getValue());

        try {
            testExceptionHandling();
        } catch (Exception e) {
            System.err.println("Caught exception: " + e.getMessage());
        }
    }

    private String processInput(String input) {
        if (input == null) {
            throw new IllegalArgumentException("Input cannot be null");
        }
        StringBuilder sb = new StringBuilder();
        for (int i = input.length() - 1; i >= 0; i--) {
            sb.append(input.charAt(i));
        }
        return sb.toString();
    }

    private Map<String, Integer> countOccurrences(List<String> list) {
        Map<String, Integer> map = new HashMap<>();
        for (String s : list) {
            if (s == null) continue;
            map.put(s, map.getOrDefault(s, 0) + 1);
        }
        return map;
    }

    private void testExceptionHandling() throws Exception {
        int attempt = 0;
        while (attempt < MAX_RETRIES) {
            try {
                riskyOperation(attempt);
                System.out.println("Operation succeeded on attempt " + attempt);
                return;
            } catch (IOException e) {
                System.err.println("IOException on attempt " + attempt + ": " + e.getMessage());
                attempt++;
            } finally {
                System.out.println("Attempt " + attempt + " completed.");
            }
        }
        throw new Exception("All retries failed");
    }

    private void riskyOperation(int attempt) throws IOException {
        if (attempt < 2) {
            throw new IOException("Simulated IO failure");
        }
        System.out.println("Risky operation successful");
    }

    // Nested static class
    static class NestedClass {
        void printMessage() {
            System.out.println("Hello from NestedClass!");
        }
    }

    // Anonymous Runnable class
    static class AnonymousRunnable implements Runnable {
        public void run() {
            System.out.println("Running in a separate thread.");
            for (int i = 0; i < 5; i++) {
                System.out.println("Thread count: " + i);
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    System.err.println("Thread interrupted");
                }
            }
        }
    }

    // Generic class
    static class GenericContainer<T> {
        private T value;

        public GenericContainer(T value) {
            this.value = value;
        }

        public T getValue() {
            return value;
        }

        public void setValue(T value) {
            this.value = value;
        }
    }

    // Interface with default and static methods
    interface Calculator {
        int add(int a, int b);
        int subtract(int a, int b);

        default int multiply(int a, int b) {
            return a * b;
        }

        static int divide(int a, int b) {
            if (b == 0) throw new ArithmeticException("Division by zero");
            return a / b;
        }
    }

    // Implementation of interface
    static class SimpleCalculator implements Calculator {
        public int add(int a, int b) { return a + b; }

        public int subtract(int a, int b) { return a - b; }
    }

    // Enum with methods and fields
    enum Day {
        MONDAY("Start of workweek"),
        FRIDAY("End of workweek"),
        SATURDAY("Weekend"),
        SUNDAY("Weekend");

        private String description;

        Day(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }

        public boolean isWeekend() {
            return this == SATURDAY || this == SUNDAY;
        }
    }

    // Method demonstrating switch with enum
    public void printDayMessage(Day day) {
        switch (day) {
            case MONDAY:
                System.out.println("Ugh, it's Monday");
                break;
            case FRIDAY:
                System.out.println("TGIF!");
                break;
            case SATURDAY:
            case SUNDAY:
                System.out.println("Enjoy the weekend");
                break;
            default:
                System.out.println("Just another day");
        }
    }
}

