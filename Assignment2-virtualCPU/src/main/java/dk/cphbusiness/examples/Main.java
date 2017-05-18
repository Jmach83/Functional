package dk.cphbusiness.examples;

import dk.cphbusiness.virtualcpu.Machine;
import dk.cphbusiness.virtualcpu.Program;
import java.util.Scanner;

public class Main {
  
  public static void main(String[] args)
    {
        System.out.println("Welcome to the awesome CPU program");
        //Program program = new Program("01000010", "MOV A +5", "00001111", "MOV B +3");
        Program program = new Program("00010110","00010100","00000010", "00000001","00000011", "00101011");

        //Faculty program
        //Program program = new Program("01001010", "00010000", "00001100", "00010010", "00001111", "00110010", "00000111", "10001100", "01000010", "00100001", "00011000", "00010000", "00010111", "00010000", "00001100", "11000110", "00010011", "00010010", "00000010", "00100001", "00011000");
        Machine machine = new Machine();
        machine.load(program);
        machine.print(System.out);

        Scanner scanner = new Scanner(System.in);
        System.out.println("Press enter to run next line");
        String input = scanner.nextLine();

        while (!input.equalsIgnoreCase("quit"))
        {
            machine.tick();

            if (machine.getCpu().isRunning() == false)
            {
                break;
            }

            machine.print(System.out);
            System.out.println("Press enter to run next line");
            input = scanner.nextLine();
        }

    }
//  static void foo(int a, int b) {
//    System.out.println("Foo called with "+a+" and "+b);
//    }
//  
//  public static void main(String[] args) {
//    System.out.println("Starting example");
//    System.out.println("Hello world!");
//    foo(7, 17);
//    System.out.println("Printing stuff");
//    System.out.println("Getting bored");
//    foo(9, 20);
//    System.out.println("At the end");
//    }

  }
