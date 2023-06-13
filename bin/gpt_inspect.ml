open Cmdliner

let sizeof = 128

let print_gpt_header gpt =
  Printf.printf "GPT header:\n";
  Printf.printf "  signature: %s\n" gpt.Gpt.signature;
  Printf.printf "  revision: %ld\n" gpt.Gpt.revision;
  Printf.printf "  gpt-size: %ld\n" gpt.Gpt.header_size;
  Printf.printf "  gpt-checksum: %ld\n" gpt.Gpt.header_crc32;
  Printf.printf "  reserved: %ld\n" gpt.Gpt.reserved;
  Printf.printf "  current-lba: %Ld\n" gpt.Gpt.current_lba;
  Printf.printf "  backup-lba: %Ld\n" gpt.Gpt.backup_lba;
  Printf.printf "  first-usable-lba: %Ld\n" gpt.Gpt.first_usable_lba;
  Printf.printf "  last-usable-lba: %Ld\n" gpt.Gpt.last_usable_lba;
  Printf.printf "  disk-guid: %s\n" gpt.Gpt.disk_guid;
  Printf.printf "  first-partition-lba: %Ld\n" gpt.Gpt.partition_entry_lba;
  Printf.printf "  total-partitions: %d\n" gpt.Gpt.num_partition_entries;
  Printf.printf "  partition-size: %ld\n" gpt.Gpt.partition_size;
  Printf.printf "  partitions-checksum: %ld\n" gpt.Gpt.partitions_crc32;
  Printf.printf "  Partitions: \n";
  List.iteri
    (fun i part ->
      Printf.printf "  Partition %d:\n" (i + 1);
      Printf.printf "    name: %s\n" part.Gpt.Partition.name;
      Printf.printf "    type-guid: %s\n" part.Gpt.Partition.type_guid;
      Printf.printf "    partition-guid: %s\n" part.Gpt.Partition.partition_guid;
      Printf.printf "    attributes: %Ld\n" part.Gpt.Partition.attributes;
      Printf.printf "    starting-lba: %Ld\n" part.Gpt.Partition.starting_lba;
      Printf.printf "    ending-lba: %Ld\n" part.Gpt.Partition.ending_lba;
    )
    gpt.partitions

let read_gpts gpts =
  List.iter
    (fun gpt ->
      let ic = open_in_bin gpt in
      let buf = Bytes.create sizeof in
      let () = really_input ic buf 0 sizeof in
      close_in ic;
      match Gpt.unmarshal (Cstruct.of_bytes buf) with
      | Ok gpt -> print_gpt_header gpt
      | Error msg ->
          Printf.printf "Failed to read GPT from %s: %s\n" gpt msg;
          exit 1)
    gpts

let gpts = Arg.(non_empty & pos_all file [] & info [] ~docv:"disk_images")

let cmd =
  let doc =
    "Inspect the GUID Partition Table (GPT) headers of one or more disk images."
  in
  let info = Cmd.info "gpt_inspect" ~version:"1.0.0" ~doc in
  Cmd.v info Term.(const read_gpts $ gpts)

let main () = exit (Cmd.eval cmd)
let () = main ()