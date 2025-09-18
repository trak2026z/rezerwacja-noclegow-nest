import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Delete,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { RoomsService } from './rooms.service';
import { CreateRoomDto } from './dto/create-room.dto';
import { UpdateRoomDto } from './dto/update-room.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

// Definicja interfejsu dla rozszerzonego obiektu Request
interface RequestWithUser extends Request {
  user: {
    userId: string;
    username: string;
  };
}

@Controller('rooms')
export class RoomsController {
  constructor(private readonly roomsService: RoomsService) {}

  // Utworzenie pokoju
  @UseGuards(JwtAuthGuard)
  @Post()
  async create(@Body() createRoomDto: CreateRoomDto, @Req() req: RequestWithUser) {
    return this.roomsService.create(createRoomDto, req.user.userId);
  }

  // Lista wszystkich pokoi
  @Get()
  async findAll() {
    return this.roomsService.findAll();
  }

  // Szczegóły pokoju
  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.roomsService.findOne(id);
  }

  // Aktualizacja pokoju
  @UseGuards(JwtAuthGuard)
  @Put(':id')
  async update(
    @Param('id') id: string, 
    @Body() updateRoomDto: UpdateRoomDto, 
    @Req() req: RequestWithUser
  ) {
    return this.roomsService.update(id, updateRoomDto, req.user.userId);
  }

  // Usunięcie pokoju
  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async remove(@Param('id') id: string, @Req() req: RequestWithUser) {
    return this.roomsService.remove(id, req.user.userId);
  }

  // Reakcja like
  @UseGuards(JwtAuthGuard)
  @Post(':id/like')
  async handleLike(
    @Param('id') id: string,
    @Req() req: RequestWithUser,
  ) {
    return this.roomsService.handleReaction(id, req.user.userId, 'like');
  }

  // Reakcja dislike
  @UseGuards(JwtAuthGuard)
  @Post(':id/dislike')
  async handleDislike(
    @Param('id') id: string,
    @Req() req: RequestWithUser,
  ) {
    return this.roomsService.handleReaction(id, req.user.userId, 'dislike');
  }

  // Rezerwacja pokoju
  @UseGuards(JwtAuthGuard)
  @Post(':id/reserve')
  async reserveRoom(@Param('id') id: string, @Req() req: RequestWithUser) {
    return this.roomsService.reserveRoom(id, req.user.userId);
  }
}
