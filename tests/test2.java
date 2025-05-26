package com.example.test;

import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * A large test file meant to stress‑test the Java parser.
 */
public class LargeTest implements Runnable, Comparable<LargeTest>, Closeable {

    /* ---------- Static fields ---------- */
    private static final String VERSION = "1.0.0";
    private static final Map<String, Integer> STATIC_CACHE = new HashMap<>();

    /* ---------- Instance fields ---------- */
    private final int id;
    private String name;
    private List<Double> values = new ArrayList<>();
    private final Deque<Runnable> deferred = new ArrayDeque<>();

    /* ---------- Constructors ---------- */
    public LargeTest(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public LargeTest(int id) {
        this(id, "Unnamed_" + id);
    }

    /* ---------- Factory method with generics ---------- */
    // public static <T extends Number> List<T> repeat(T value, int count) {
    //     List<T> list = new ArrayList<>();
    //     for (int i = 0; i < count; i++) {
    //         list.add(value);
    //     }
    //     return Collections.unmodifiableList(list);
    // }

    /* ---------- Overloaded add methods ---------- */
    public void add(double v) { values.add(v); }
    public void add(int v)    { values.add((double) v); }

    /* ---------- Example of varargs ---------- */
    public void addAll(double... vals) {
        for (double v : vals) values.add(v);
    }

    /* ---------- Example method using streams ---------- */
    public double average() {
        return values.stream()
                     .mapToDouble(Double::doubleValue)
                     .average()
                     .orElse(Double.NaN);
    }

    /* ---------- Example of nested loops and switch ---------- */
    public void processMatrix(int[][] matrix) {
        outer:
        for (int r = 0; r < matrix.length; r++) {
            for (int c = 0; c < matrix[r].length; c++) {
                switch (matrix[r][c]) {
                    case 0: continue;
                    case -1: break outer;
                    default: System.out.printf("[%d,%d]=%d%n", r, c, matrix[r][c]);
                }
            }
        }
    }

    /* ---------- Anonymous class and lambda ---------- */
    public void sortValuesDescending() {
        values.sort(new Comparator<Double>() {
            @Override
            public int compare(Double a, Double b) {
                return -a.compareTo(b);
            }
        });
        // Same with lambda
        values.sort((a, b) -> Double.compare(b, a));
    }

    /* ---------- Method demonstrating exceptions ---------- */
    public String readFirstLine(Path path) throws IOException {
        try {
            return Files.lines(path)
                        .findFirst()
                        .orElseThrow(() -> new IOException("File empty"));
        } finally {
            System.out.println("readFirstLine finished for " + path);
        }
    }

    /* ---------- Inner class ---------- */
    public class Worker {
        public void run() {
            deferred.forEach(Runnable::run);
        }
    }

    /* ---------- Enum ---------- */
    public enum State {
        NEW, RUNNING, FINISHED, FAILED
    }

    /* ---------- Interface inside class ---------- */
    public interface Callback {
        void onComplete(State state, Optional<Exception> error);
    }

    /* ---------- Runnable implementation ---------- */
    @Override
    public void run() {
        System.out.println("Running task " + name);
        Worker worker = new Worker();
        worker.run();
    }

    /* ---------- Comparable implementation ---------- */
    @Override
    public int compareTo(LargeTest other) {
        return Integer.compare(this.id, other.id);
    }

    /* ---------- Closeable implementation ---------- */
    @Override
    public void close() {
        System.out.println("Closed LargeTest " + id);
    }

    /* ---------- Generics + wildcards ---------- */
    public static double sumList(List<? extends Number> nums) {
        double sum = 0;
        for (Number n : nums) sum += n.doubleValue();
        return sum;
    }

    /* ---------- Static utility method ---------- */
    public static int randBetween(int minInclusive, int maxExclusive) {
        return new Random().ints(minInclusive, maxExclusive).findFirst().getAsInt();
    }

    /* ---------- Var‑enum usage ---------- */
    public static void main(String[] args) {
        LargeTest test = new LargeTest(1, "Demo");
        test.addAll(1, 2, 3, 4.5);
        System.out.println("Average = " + test.average());

        int[][] matrix = {
            {1, 0, 2},
            {3, 4, -1},
            {5, 6, 7}
        };
        test.processMatrix(matrix);

        IntStream.range(0, 5).forEach(i ->
            test.deferred.add(() -> System.out.println("Deferred " + i))
        );
        test.run();

        try (LargeTest t2 = new LargeTest(2)) {
            System.out.println("Random = " + randBetween(10, 20));
        }
    }
}
