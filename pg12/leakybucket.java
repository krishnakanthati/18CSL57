import java.util.*;

class queue {
    int q[], f = 0, r = 0, size;

    void insert(int n) {
        Scanner in = new Scanner(System.in);
        q = new int[15];
        for (int i = 0; i < n; i++) {
            System.out.println("\nenter " + i + " element:");
            int ele = in.nextInt();
            if (r + 1 > 15) {
                System.out.println("\nqueue is full\nlost packet:" + ele);
                break;
            } else {
                r++;
                q[i] = ele;
            }
        }
    }

    void delete() {
        Scanner in = new Scanner(System.in);
        Thread t = new Thread();
        if (r == 0)
            System.out.println("\nqueue empty");
        else {
            for (int i = f; i < r; i++) {
                try {
                    t.sleep(1000);
                } catch (Exception e) {
                }
                System.out.print("\nleaked packet: " + q[i]);
                f++;
            }
        }
        System.out.println();
    }
}

class leakybucket extends Thread {
    public static void main(String ar[]) throws Exception {
        queue q = new queue();
        Scanner src = new Scanner(System.in);
        System.out.println("\nenter no of packets to be sent:");
        int size = src.nextInt();
        q.insert(size);
        q.delete();
    }
}
