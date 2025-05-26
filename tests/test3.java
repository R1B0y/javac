package com.example.test;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.*;

/**
 * Тестовый класс для стресс-тестирования парсера.
 */
@Deprecated
public class ParserStressTest<T extends Number & Comparable<T>, U>
        implements Comparable<ParserStressTest>, Runnable, Closeable {
    /* ---------- Instance initializer ---------- */

    /* ---------- Fields ---------- */
    private int x;
    protected String[] names;
    List<String> list = new ArrayList<>();
    Map<String, int> map = new HashMap<>();
    Optional<? extends Runnable> opt = Optional.empty();
    T genericField;
    U otherGeneric;

    /* ---------- Constructors ---------- */
    public ParserStressTest() {
        this(0);
    }

    public ParserStressTest(int x) {
        this.x = x;
        // локальный класс
        class LocalHelper {
            void help() { System.out.println("LocalHelper.help()"); }
        }
        new LocalHelper().help();
    }

    /* ---------- Generic method ---------- */
    public <V extends CharSequence> V echo(V value) {
        return value;
    }

    public static <K, V> Map<K, V> singletonMap(K key, V value) {
        Map<K, V> m = new HashMap<>();
        m.put(key, value);
        return m;
    }

    /* ---------- Varargs ---------- */
    public void varargsTest(String... args) {
        for (String s : args) System.out.println(s);
    }

    /* ---------- Nested loops + label + switch ---------- */
    public void processMatrix(int[][] matrix) {
        outer:
        for (int i = 0; i < matrix.length; i++) {
            for (int j = 0; j < matrix[i].length; j++) {
                switch (matrix[i][j]) {
                    case 0:
                        continue outer;
                    case -1:
                        break outer;
                    default:
                        System.out.printf("matrix[%d][%d]=%d%n", i, j, matrix[i][j]);
                }
            }
        }
    }

    /* ---------- Lambdas & streams ---------- */
    public void lambdaAndStreams() {
        list.sort(String::compareToIgnoreCase);
        List<String> upper = list.stream()
            .filter(Objects::nonNull)
            .map(String::toUpperCase)
            .collect(Collectors.toList());
        System.out.println(upper);
    }

    /* ---------- Anonymous inner class ---------- */
    public void anonymousClass() {
        Runnable r = new Runnable() {
            @Override
            public void run() {
                System.out.println("AnonymousRunnable.run()");
            }
        };
        r.run();
    }

    /* ---------- try-with-resources, catch, finally ---------- */
    public void tryTest() throws IOException {
        try (BufferedReader br = Files.newBufferedReader(Paths.get("test.txt"))) {
            String line;
            while ((line = br.readLine()) != null) {
                System.out.println(line);
            }
        } catch (FileNotFoundException fnf) {
            fnf.printStackTrace();
        } finally {
            System.out.println("Cleaning up");
        }
    }

    /* ---------- Runnable impl ---------- */
    @Override
    public void run() {
        System.out.println("Runnable.run()");
    }

    /* ---------- Comparable impl ---------- */
    @Override
    public int compareTo(ParserStressTest<T, U> o) {
        return Integer.compare(this.x, o.x);
    }

    /* ---------- Closeable impl ---------- */
    @Override
    public void close() {
        System.out.println("Closeable.close()");
    }

    /* ---------- Enum ---------- */
    public enum Day {
        MONDAY("Start"), FRIDAY("End"), SATURDAY("Weekend"), SUNDAY("Weekend");

        private final String desc;
        Day(String d) { this.desc = d; }
        public String getDesc() { return desc; }
    }

    /* ---------- Interface with default & static ---------- */
    public interface Calculator {
        int add(int a, int b);
        int sub(int a, int b);
        default int mul(int a, int b) { return a * b; }
        static int div(int a, int b) {
            if (b == 0) throw new ArithmeticException("Divide by zero");
            return a / b;
        }
    }

    /* ---------- Static nested class ---------- */
    static class Nested {
        void msg() { System.out.println("Nested.msg()"); }
    }

    public void testNested() {
        new Nested().msg();
    }

    public static void main(String[] args) {
        ParserStressTest<Integer, String> test = new ParserStressTest<>(5);
        test.varargsTest("one", "two", "three");
        test.processMatrix(new int[][] { {1,2}, {3,4,5} });
        test.lambdaAndStreams();
        test.anonymousClass();
        try {
            test.tryTest();
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println(test.echo("Hello, Generics!"));
        System.out.println(singletonMap("key", 123));
        test.run();
        test.close();
        System.out.println(Day.MONDAY.getDesc());
        test.list.forEach(System.out::println);
    }
}

