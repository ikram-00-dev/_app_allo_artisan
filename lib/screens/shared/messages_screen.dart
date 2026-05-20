/// ============================================================
/// MESSAGE SCREEN
/// lib/screens/messages_screen.dart
/// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/message.dart';
import '../services/api_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() =>
      _MessagesScreenState();
}

class _MessagesScreenState
    extends State<MessagesScreen> {

  /// =========================================================
  /// VARIABLES
  /// =========================================================

  final TextEditingController searchController =
  TextEditingController();

  final TextEditingController messageController =
  TextEditingController();

  bool isLoadingContacts = false;
  bool isLoadingMessages = false;

  List<dynamic> contacts = [];

  List<Message> messages = [];

  dynamic selectedContact;

  /// change according to logged user role
  /// true => artisan
  /// false => client
  bool isArtisan = false;

  /// =========================================================
  /// INIT
  /// =========================================================

  @override
  void initState() {
    super.initState();

    fetchContacts();
  }

  /// =========================================================
  /// FETCH CONTACTS
  /// =========================================================

  Future<void> fetchContacts() async {
    try {
      setState(() {
        isLoadingContacts = true;
      });

      /// BACKEND ENDPOINT
      /// Example:
      /// GET /messages/contacts
      final response = await ApiService.get(
        '/messages/contacts',
      );

      setState(() {
        contacts = response;
      });
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoadingContacts = false;
      });
    }
  }

  /// =========================================================
  /// FETCH MESSAGES
  /// =========================================================

  Future<void> fetchMessages(
      int contactId) async {
    try {
      setState(() {
        isLoadingMessages = true;
      });

      /// BACKEND ENDPOINT
      /// Example:
      /// GET /messages/contact/1
      final response = await ApiService.get(
        '/messages/contact/$contactId',
      );

      final List<Message> loadedMessages =
      (response as List)
          .map(
            (json) => Message.fromJson(json),
      )
          .toList();

      setState(() {
        messages = loadedMessages;
      });
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoadingMessages = false;
      });
    }
  }

  /// =========================================================
  /// SEND MESSAGE
  /// =========================================================

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty ||
        selectedContact == null) {
      return;
    }

    try {
      final data = {
        "text":
        messageController.text.trim(),
        "contact_id":
        selectedContact["id_user"] ??
            selectedContact["id"],
        "is_sent_to_client":
        isArtisan,
        "seen": false,
      };

      /// BACKEND ENDPOINT
      /// POST /messages
      final response = await ApiService.post(
        '/messages',
        data,
      );

      final newMessage =
      Message.fromJson(response);

      setState(() {
        messages.add(newMessage);
      });

      messageController.clear();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// =========================================================
  /// FILTERED CONTACTS
  /// =========================================================

  List<dynamic> get filteredContacts {
    return contacts.where((contact) {
      final name =
      (contact["username"] ??
          contact["name"] ??
          "")
          .toString()
          .toLowerCase();

      return name.contains(
        searchController.text
            .toLowerCase(),
      );
    }).toList();
  }

  /// =========================================================
  /// UI
  /// =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xffF5F5F5),

      body: SafeArea(
        child: selectedContact == null
            ? buildContactsView()
            : buildChatView(),
      ),
    );
  }

  /// =========================================================
  /// CONTACTS VIEW
  /// =========================================================

  Widget buildContactsView() {
    return Column(
      children: [

        /// HEADER
        Container(
          padding:
          const EdgeInsets.all(16),
          color: Colors.white,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              const Text(
                "Messages",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                searchController,

                onChanged: (_) {
                  setState(() {});
                },

                decoration: InputDecoration(
                  hintText:
                  "Rechercher...",
                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),

                  filled: true,
                  fillColor:
                  const Color(
                    0xffF5F5F5,
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// CONTACTS
        Expanded(
          child: isLoadingContacts
              ? const Center(
            child:
            CircularProgressIndicator(),
          )
              : filteredContacts.isEmpty
              ? const Center(
            child: Text(
              "Aucun contact",
            ),
          )
              : ListView.builder(
            itemCount:
            filteredContacts
                .length,

            itemBuilder:
                (context, index) {
              final contact =
              filteredContacts[
              index];

              return InkWell(
                onTap: () async {
                  setState(() {
                    selectedContact =
                        contact;
                  });

                  await fetchMessages(
                    contact[
                    "id_user"] ??
                        contact[
                        "id"],
                  );
                },

                child: Container(
                  padding:
                  const EdgeInsets
                      .all(16),

                  decoration:
                  const BoxDecoration(
                    color:
                    Colors.white,
                    border: Border(
                      bottom:
                      BorderSide(
                        color: Color(
                            0xffEEEEEE),
                      ),
                    ),
                  ),

                  child: Row(
                    children: [

                      /// AVATAR
                      CircleAvatar(
                        radius: 28,
                        backgroundImage:
                        NetworkImage(
                          contact[
                          "profile_image"] ??
                              "https://ui-avatars.com/api/?name=${contact["username"]}",
                        ),
                      ),

                      const SizedBox(
                          width: 12),

                      /// INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              contact["username"] ??
                                  "",
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize:
                                15,
                              ),
                            ),

                            const SizedBox(
                                height:
                                4),

                            Text(
                              contact["last_message"] ??
                                  "",
                              maxLines:
                              1,
                              overflow:
                              TextOverflow.ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          width: 8),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .end,
                        children: [

                          Text(
                            contact["last_time"] ??
                                "",
                            style:
                            const TextStyle(
                              color:
                              Colors.grey,
                              fontSize:
                              12,
                            ),
                          ),

                          if ((contact[
                          "unread_count"] ??
                              0) >
                              0)
                            Container(
                              margin:
                              const EdgeInsets
                                  .only(
                                top: 6,
                              ),

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal:
                                8,
                                vertical:
                                4,
                              ),

                              decoration:
                              const BoxDecoration(
                                color:
                                Colors.blue,
                                shape:
                                BoxShape.circle,
                              ),

                              child: Text(
                                contact[
                                "unread_count"]
                                    .toString(),
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize:
                                  11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// =========================================================
  /// CHAT VIEW
  /// =========================================================

  Widget buildChatView() {
    return Column(
      children: [

        /// TOP BAR
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),

          color: Colors.white,

          child: Row(
            children: [

              IconButton(
                onPressed: () {
                  setState(() {
                    selectedContact = null;
                    messages.clear();
                  });
                },

                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),

              CircleAvatar(
                radius: 22,
                backgroundImage:
                NetworkImage(
                  selectedContact[
                  "profile_image"] ??
                      "https://ui-avatars.com/api/?name=${selectedContact["username"]}",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    Text(
                      selectedContact[
                      "username"] ??
                          "",
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      selectedContact[
                      "online"] ==
                          true
                          ? "En ligne"
                          : "Hors ligne",
                      style:
                      const TextStyle(
                        color:
                        Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {},

                icon: const Icon(
                  Icons.more_vert,
                ),
              ),
            ],
          ),
        ),

        /// MESSAGES
        Expanded(
          child: isLoadingMessages
              ? const Center(
            child:
            CircularProgressIndicator(),
          )
              : ListView.builder(
            padding:
            const EdgeInsets
                .all(16),

            itemCount:
            messages.length,

            itemBuilder:
                (context, index) {
              final message =
              messages[index];

              final isMe = message
                  .isSentByCurrentUser(
                isArtisan,
              );

              return Align(
                alignment: isMe
                    ? Alignment
                    .centerRight
                    : Alignment
                    .centerLeft,

                child: Container(
                  margin:
                  const EdgeInsets
                      .only(
                    bottom: 12,
                  ),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),

                  constraints:
                  const BoxConstraints(
                    maxWidth: 280,
                  ),

                  decoration:
                  BoxDecoration(
                    color: isMe
                        ? Colors.blue
                        : Colors.white,

                    borderRadius:
                    BorderRadius
                        .circular(
                      18,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .end,

                    children: [

                      Text(
                        message.text,
                        style:
                        TextStyle(
                          color: isMe
                              ? Colors
                              .white
                              : Colors
                              .black87,
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Text(
                        message
                            .formattedTime,
                        style:
                        TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors
                              .white70
                              : Colors
                              .grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// INPUT
        Container(
          padding:
          const EdgeInsets.all(12),
          color: Colors.white,

          child: Row(
            children: [

              Expanded(
                child: TextField(
                  controller:
                  messageController,

                  decoration:
                  InputDecoration(
                    hintText:
                    "Tapez votre message...",
                    filled: true,
                    fillColor:
                    const Color(
                      0xffF5F5F5,
                    ),

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        30,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: sendMessage,

                child: Container(
                  padding:
                  const EdgeInsets
                      .all(12),

                  decoration:
                  const BoxDecoration(
                    color: Colors.blue,
                    shape:
                    BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}